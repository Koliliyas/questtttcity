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

from api.api_router import router_v1
from api.exceptions import BaseHTTPError, ServerHTTPError
from core.di.container import create_container
from logger import get_logger
from settings import ApplicationSettings, get_settings

logger = get_logger(__name__)


@contextlib.asynccontextmanager
async def _lifespan(
    app: FastAPI,  # noqa: ARG001 - required by lifespan protocol
) -> AsyncIterator[None]:
    async with contextlib.aclosing(create_container()):
        yield


async def http_exception_handler(
    request: Request,  # noqa: ARG001
    exc: BaseHTTPError,
) -> JSONResponse:
    return JSONResponse(
        content=jsonable_encoder(exc.error_schema.model_dump(by_alias=True)),
        status_code=exc.status_code,
    )


# TODO: refactor this shit


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
