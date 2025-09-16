import base64
import mimetypes
import uuid
from dataclasses import asdict
from io import BytesIO
from pathlib import Path
from typing import (Any, Generic, Optional, Sequence, Type,
                    TypeVar)
from urllib.parse import urlparse

import magic
from aioboto3 import Session
from botocore.client import BaseClient
from botocore.config import Config
from botocore.exceptions import ClientError
from fastapi.encoders import jsonable_encoder
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.base import Base
from src.settings import S3Settings
from src.core.base.repositories import S3BaseRepository

ModelType = TypeVar("ModelType", bound=Base)


class BaseSQLAlchemyRepository(Generic[ModelType]):
    def __init__(self, session: AsyncSession, model: Type[ModelType]) -> None:
        self._session = session
        self._model = model

    async def create(self, dto) -> ModelType:
        self._session.add(model := self._model(**asdict(dto)))
        await self._session.flush()
        return model

    async def get_by_oid(self, oid: int) -> ModelType | None:
        import logging
        logger = logging.getLogger(__name__)
        
        logger.info(f"BaseSQLAlchemyRepository.get_by_oid - Запрос {self._model.__name__} с ID = {oid}")
        logger.info(f"BaseSQLAlchemyRepository.get_by_oid - Сессия: {self._session}")
        logger.info(f"BaseSQLAlchemyRepository.get_by_oid - Модель: {self._model}")
        
        # ДОПОЛНИТЕЛЬНОЕ ЛОГИРОВАНИЕ: Проверяем состояние сессии
        logger.info(f"BaseSQLAlchemyRepository.get_by_oid - Сессия активна: {self._session.is_active}")
        logger.info(f"BaseSQLAlchemyRepository.get_by_oid - Сессия в транзакции: {self._session.in_transaction()}")
        
        try:
            # Заменяем session.get() на более надежный session.scalar(select())
            from sqlalchemy import select
            stmt = select(self._model).where(self._model.id == oid)
            logger.info(f"BaseSQLAlchemyRepository.get_by_oid - SQL запрос: {stmt}")
            
            result = await self._session.scalar(stmt)
            logger.info(f"BaseSQLAlchemyRepository.get_by_oid - Результат: {result}")
            
            # ДОПОЛНИТЕЛЬНОЕ ЛОГИРОВАНИЕ: Проверяем через прямой SQL
            if result is None:
                logger.warning(f"BaseSQLAlchemyRepository.get_by_oid - Результат None, проверяем через прямой SQL...")
                from sqlalchemy import text
                sql_result = await self._session.execute(text(f"SELECT * FROM {self._model.__tablename__} WHERE id = {oid}"))
                sql_row = sql_result.fetchone()
                logger.warning(f"BaseSQLAlchemyRepository.get_by_oid - Прямой SQL результат: {sql_row}")
            
            return result
        except Exception as e:
            logger.error(f"BaseSQLAlchemyRepository.get_by_oid - Исключение: {e}")
            raise

    async def get_by_attr(
        self,
        attr_name: str,
        attr_value: Any,
    ) -> Optional[ModelType]:
        return await self._session.scalar(
            select(self._model).where(
                getattr(self._model, attr_name) == attr_value,
            )
        )

    async def get_all(self) -> Sequence[ModelType]:
        return (await self._session.scalars(select(self._model))).all()

    async def update(self, instance: ModelType, dto) -> ModelType:
        obj_data = jsonable_encoder(instance)

        update_data = asdict(dto)

        for field in obj_data:
            if field in update_data:
                setattr(instance, field, update_data[field])

        self._session.add(instance)
        await self._session.flush()
        return instance

    async def delete(self, obj: ModelType) -> None:
        await self._session.delete(obj)
        await self._session.flush()


import logging
from src.core.resilience import (
    retry_with_backoff,
    S3_RETRY_CONFIG,
    circuit_breaker, 
    S3_CIRCUIT_BREAKER_CONFIG
)
from src.core.resilience.health_check import get_health_checker

logger = logging.getLogger(__name__)


class S3UnavailableError(Exception):
    """Исключение когда S3/MinIO недоступен"""
    pass


@retry_with_backoff(S3_RETRY_CONFIG)
@circuit_breaker("s3", S3_CIRCUIT_BREAKER_CONFIG)
async def create_s3_client(settings: S3Settings) -> BaseClient:
    """
    Создает S3 клиент с resilience механизмами.
    
    Args:
        settings: Настройки S3
        
    Returns:
        BaseClient: Клиент S3
        
    Raises:
        S3UnavailableError: Если S3 недоступен
    """
    health_checker = get_health_checker()
    
    # Проверяем статус S3 через health checker
    if not health_checker.is_service_available("s3"):
        logger.warning("S3/MinIO недоступен по health check")
        raise S3UnavailableError("S3 storage is currently unavailable")
    
    try:
        session = Session()
        client = await session.client(
            service_name="s3",
            endpoint_url=settings.endpoint,
            aws_access_key_id=settings.access_key,
            aws_secret_access_key=settings.secret_key,
            config=Config(
                signature_version="s3v4",
                connect_timeout=settings.connect_timeout,
                read_timeout=settings.read_timeout,
                retries={
                    "max_attempts": settings.max_attempts,
                    "mode": settings.mode,
                },
                # Дополнительные настройки для resilience
                max_pool_connections=50,
            ),
        ).__aenter__()
        
        # Проверяем доступность bucket
        try:
            await client.head_bucket(Bucket=settings.bucket_name)
            logger.debug(f"S3 bucket '{settings.bucket_name}' доступен")
        except ClientError as error:
            if error.response["Error"]["Code"] == "404":
                logger.info(f"Создание S3 bucket: {settings.bucket_name}")
                await client.create_bucket(Bucket=settings.bucket_name)
            else:
                logger.error(f"Ошибка доступа к S3 bucket: {error}")
                raise
        
        return client
        
    except Exception as e:
        logger.error(f"Ошибка создания S3 клиента: {e}")
        raise S3UnavailableError(f"Failed to create S3 client: {e}")


class S3Repository(S3BaseRepository):
    """
    Реализация репозитория для S3-совместимых хранилищ (MinIO, AWS S3).
    
    Наследуется от S3BaseRepository и может добавлять специфичную логику,
    если потребуется в будущем.
    """
    
    def __init__(self, client: BaseClient, settings: S3Settings):
        """
        Инициализация S3Repository.
        
        Args:
            client: S3-совместимый клиент (boto3/aioboto3)
            settings: Настройки подключения к S3
        """
        super().__init__(client, settings)
