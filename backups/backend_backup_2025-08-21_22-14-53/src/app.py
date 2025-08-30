import contextlib
from typing import AsyncIterator

from aioinject.ext.fastapi import AioInjectMiddleware
from fastapi import FastAPI
from fastapi.encoders import jsonable_encoder
from fastapi.middleware.cors import CORSMiddleware
from fastapi.requests import Request
from fastapi.responses import JSONResponse
from fastapi_pagination import add_pagination
from starlette.middleware.sessions import SessionMiddleware

from src.api.api_router import router_v1
from src.api.exceptions import (
    BaseHTTPError, 
    ServerHTTPError,
    FileTooLargeHTTPError,
    InvalidFileTypeHTTPError,
    SuspiciousFileContentHTTPError,
    VirusDetectedHTTPError,
    EmptyFileHTTPError,
    CorruptedFileHTTPError,
    ZipBombHTTPError,
    UnsafeFilenameHTTPError,
    FileValidationHTTPError,
    InvalidSearchTermHTTPError,
    SuspiciousSearchHTTPError,
    SearchTermTooLongHTTPError,
)
from src.core.di.container import create_container
from src.logger import get_logger
from src.settings import ApplicationSettings, get_settings

logger = get_logger(__name__)


@contextlib.asynccontextmanager
async def _lifespan(
    app: FastAPI,  # noqa: ARG001 - required by lifespan protocol
) -> AsyncIterator[None]:
    # Инициализация JWT ключей при старте приложения
    logger.info("Инициализация QuestCity Backend...")
    
    try:
        from src.core.authentication.jwt_keys import ensure_jwt_keys_exist, JWTKeysError
        from src.core.resilience.health_check import get_health_checker, register_default_health_checks
        from src.settings import get_settings, AuthJWTSettings
        
        # Получаем настройки JWT
        jwt_settings = get_settings(AuthJWTSettings)
        
        # Проверяем и создаем JWT ключи если необходимо
        ensure_jwt_keys_exist(
            private_key_path=jwt_settings.private_key_path,
            public_key_path=jwt_settings.public_key_path,
            key_size=2048
        )
        
        logger.info("✅ JWT ключи готовы к использованию")
        
        # Инициализируем Health Checker
        logger.info("Инициализация Health Checker...")
        health_checker = get_health_checker()
        
        # Регистрируем стандартные health checks
        register_default_health_checks()
        
        # Запускаем health checks
        await health_checker.start()
        
        logger.info("✅ Health Checker запущен")
        
    except JWTKeysError as e:
        logger.error(f"❌ Критическая ошибка инициализации JWT ключей: {e}")
        raise
    except Exception as e:
        logger.error(f"❌ Неожиданная ошибка при инициализации: {e}")
        raise
    
    async with contextlib.aclosing(create_container()):
        logger.info("🚀 QuestCity Backend запущен успешно")
        yield
        
        # Graceful shutdown
        logger.info("🛑 QuestCity Backend завершает работу...")
        
        try:
            # Останавливаем Health Checker
            health_checker = get_health_checker()
            await health_checker.stop()
            logger.info("✅ Health Checker остановлен")
        except Exception as e:
            logger.error(f"Ошибка при остановке Health Checker: {e}")
        
        logger.info("✅ QuestCity Backend завершен")


# Импортируем рефакторенные обработчики исключений
from src.core.exceptions.handlers import http_exception_handler, file_validation_exception_handler


async def search_security_exception_handler(
    request: Request,  # noqa: ARG001
    exc: ValueError,
) -> JSONResponse:
    """Обработчик исключений безопасности поиска."""
    
    exc_message = str(exc)
    
    # Проверяем, что это исключение из FuzzySearchService
    if any(keyword in exc_message for keyword in [
        'Search term', 'similarity limit', 'suspicious pattern', 'too long', 'control characters'
    ]):
        # Определяем тип исключения по сообщению
        if 'too long' in exc_message:
            # Извлекаем длину из сообщения для более точного ответа
            import re
            match = re.search(r'(\d+) characters', exc_message)
            length = int(match.group(1)) if match else 0
            http_exc = SearchTermTooLongHTTPError(length, 1000)
        elif 'suspicious pattern' in exc_message:
            # Извлекаем паттерн из сообщения
            import re
            match = re.search(r"pattern: '([^']+)'", exc_message)
            pattern = match.group(1) if match else 'unknown'
            http_exc = SuspiciousSearchHTTPError(pattern)
        else:
            # Общее исключение поиска
            http_exc = InvalidSearchTermHTTPError(exc_message)
        
        # Логируем событие безопасности
        logger.warning(f"Search security violation: {exc}", extra={
            'event': 'search_security_violation',
            'error_message': exc_message,
            'client_ip': request.client.host if request.client else 'unknown',
            'user_agent': request.headers.get('user-agent', 'unknown'),
            'url': str(request.url),
        })
        
        return JSONResponse(
            content=jsonable_encoder(http_exc.error_schema.model_dump(by_alias=True)),
            status_code=http_exc.status_code,
        )
    
    # Если это не исключение поиска, передаем дальше
    raise exc


async def exception_handler(
    request: Request,
    exc: Exception,
) -> JSONResponse:
    logger.exception(exc)
    exc = ServerHTTPError()
    return JSONResponse(
        content=jsonable_encoder(exc.error_schema.model_dump(by_alias=True)),
        status_code=exc.status_code,
    )


def create_app() -> FastAPI:
    app = FastAPI(
        lifespan=_lifespan,
        title="Questcity",
        docs_url="/api/docs",
        redoc_url="/api/redoc",
    )
    settings: ApplicationSettings = get_settings(ApplicationSettings)
    add_pagination(app)
    app.include_router(
        router=router_v1,
        prefix="/api",
    )

    app.exception_handlers[BaseHTTPError] = http_exception_handler
    
    # Регистрируем обработчики исключений валидации файлов
    from src.core.file_validation.exceptions import FileValidationError
    app.exception_handlers[FileValidationError] = file_validation_exception_handler
    
    # Регистрируем обработчик поисковых исключений
    app.exception_handlers[ValueError] = search_security_exception_handler
    
    app.exception_handlers[Exception] = exception_handler

    app.add_middleware(SessionMiddleware, secret_key=settings.session_secret_key)
    app.add_middleware(AioInjectMiddleware, container=create_container())
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allow_origins,
        allow_credentials=True,
        allow_origin_regex=settings.allow_origin_regex,
        allow_methods=settings.allow_methods,
        allow_headers=settings.allow_headers,
    )

    return app


# Создаем экземпляр приложения для uvicorn
app = create_app()
