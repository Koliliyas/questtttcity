import base64
import mimetypes
import uuid
from contextlib import asynccontextmanager
from dataclasses import asdict
from io import BytesIO
from pathlib import Path
from typing import (Any, AsyncGenerator, Generic, Optional, Sequence, Type,
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

from db.base import Base
from settings import S3Settings

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
        return await self._session.get(self._model, oid)

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


@asynccontextmanager
async def create_s3_client(settings: S3Settings) -> AsyncGenerator[BaseClient, None]:
    async with Session().client(
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
        ),
    ) as client:
        try:
            await client.head_bucket(Bucket=settings.bucket_name)
        except ClientError as error:
            if error.response["Error"]["Code"] == "404":
                await client.create_bucket(Bucket=settings.bucket_name)

        yield client


class S3Repository:
    def __init__(self, client: BaseClient, settings: S3Settings):
        self._client = client
        self._settings = settings

    async def upload_file(
        self,
        release: str,
        content: str,
    ) -> str:
        decoded = base64.b64decode(content)

        blob_s3_key = str(
            Path(
                (
                    "excels"
                    if (
                        extension := mimetypes.guess_extension(
                            magic.Magic(mime=True).from_buffer(decoded)
                        )
                    )
                    and extension in (".xlsx", ".xls")
                    else "images"
                ),
                release,
                f"{uuid.uuid4()}{extension}",
            )
        )

        await self._client.upload_fileobj(
            Fileobj=BytesIO(decoded),
            Bucket=self._settings.bucket_name,
            Key=blob_s3_key,
        )

        return (
            f"{self._settings.browser_url}/{self._settings.bucket_name}/{blob_s3_key}"
        )

    async def delete_file(self, path: str):
        url_path = urlparse(path).path
        path_parts = url_path.split("/")

        file_key = "/".join(path_parts[3:])

        await self._client.delete_object(
            Bucket=self._settings.bucket_name,
            Key=file_key,
        )
