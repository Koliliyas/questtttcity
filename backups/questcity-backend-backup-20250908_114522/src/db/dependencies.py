import contextlib
import logging
from typing import AsyncIterator

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError

from src.api.exceptions import BaseHTTPError
from src.core.resilience import (
    retry_with_backoff, 
    DATABASE_RETRY_CONFIG,
    circuit_breaker,
    DATABASE_CIRCUIT_BREAKER_CONFIG
)
from src.core.resilience.health_check import get_health_checker
from src.db.engine import async_session_factory

logger = logging.getLogger(__name__)


class DatabaseUnavailableError(Exception):
    """Исключение когда БД недоступна"""
    pass


@retry_with_backoff(DATABASE_RETRY_CONFIG)
@circuit_breaker("database", DATABASE_CIRCUIT_BREAKER_CONFIG)
async def _create_session_with_resilience() -> AsyncSession:
    """Создает сессию БД с retry и circuit breaker защитой"""
    try:
        session = async_session_factory()
        # Проверяем что соединение работает
        from sqlalchemy import text
        await session.execute(text("SELECT 1"))
        return session
    except SQLAlchemyError as e:
        logger.error(f"Ошибка создания сессии БД: {e}")
        raise
    except Exception as e:
        logger.error(f"Неожиданная ошибка БД: {e}")
        raise


@contextlib.asynccontextmanager
async def create_session() -> AsyncIterator[AsyncSession]:
    """
    Dependency с сессией SQLAlchemy с resilience механизмами.

    Yields:
        AsyncSession: Открытая сессия БД
        
    Raises:
        DatabaseUnavailableError: Если БД недоступна
    """
    health_checker = get_health_checker()
    
    # Проверяем статус БД через health checker
    if not health_checker.is_service_available("database"):
        logger.warning("База данных недоступна по health check")
        raise DatabaseUnavailableError("Database is currently unavailable")
    
    session = None
    try:
        session = await _create_session_with_resilience()
        yield session
        # Коммитим транзакцию при успешном выполнении
        await session.commit()
    except BaseHTTPError:
        # HTTP исключения (авторизация, валидация и т.д.) должны проходить без изменений
        if session:
            await session.rollback()
        raise
    except Exception as e:
        logger.error(f"Ошибка в сессии БД: {e}")
        if session:
            await session.rollback()
        # Безопасно создаем сообщение об ошибке, избегая рекурсии
        error_msg = str(e)[:200] if str(e) else "Unknown database error"
        raise DatabaseUnavailableError(f"Database operation failed: {error_msg}")
    finally:
        if session:
            await session.close()


async def create_session_depends() -> AsyncIterator[AsyncSession]:
    """
    FastAPI dependency с сессией SQLAlchemy.

    Yields:
        AsyncSession: Открытая сессия БД
        
    Raises:
        DatabaseUnavailableError: Если БД недоступна
    """
    async with create_session() as session:
        yield session


async def create_session_without_transaction() -> AsyncIterator[AsyncSession]:
    """
    Создает сессию БД без автоматической транзакции.
    Используется для read-only операций.
    """
    health_checker = get_health_checker()
    
    # Проверяем статус БД
    if not health_checker.is_service_available("database"):
        logger.warning("База данных недоступна по health check")
        raise DatabaseUnavailableError("Database is currently unavailable")
    
    session = None
    try:
        session = await _create_session_with_resilience()
        yield session
    except Exception as e:
        logger.error(f"Ошибка в read-only сессии БД: {e}")
        # Безопасно создаем сообщение об ошибке, избегая рекурсии
        error_msg = str(e)[:200] if str(e) else "Unknown database error"
        raise DatabaseUnavailableError(f"Database read operation failed: {error_msg}")
    finally:
        if session:
            await session.close()
