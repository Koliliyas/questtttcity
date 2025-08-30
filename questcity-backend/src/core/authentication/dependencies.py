from urllib.parse import parse_qs

from fastapi import Depends, WebSocket, WebSocketException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from result import Err
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.exceptions import (AccessTokenExpiredHTTPError,
                            InvalidAccessTokenHTTPError,
                            MissingAccessTokenHTTPError,
                            PermissionDeniedHTTPError)
from src.core.authentication.exceptions import (AccessTokenExpiredError,
                                            InvalidAccessTokenError)
from src.core.authentication.repositories import (AccessTokenRepository,
                                              RefreshTokenRepository)
from src.core.authentication.services import AuthenticationService
from src.core.chat.repositories import ChatRepository
from src.core.user.repositories import UserRepository
from src.db.dependencies import create_session_depends
from src.db.models.user import User
from src.settings import AuthJWTSettings, get_settings

http_bearer = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(http_bearer),
    session: AsyncSession = Depends(create_session_depends),
):
    if not credentials:
        raise MissingAccessTokenHTTPError()
    token = credentials.credentials
    settings = get_settings(AuthJWTSettings)
    refresh_token_repository = RefreshTokenRepository(session)
    user_repository = UserRepository(session)
    access_token_repository = AccessTokenRepository(settings)
    auth_service = AuthenticationService(
        refresh_token_repository=refresh_token_repository,
        access_token_repository=access_token_repository,
        auth_settings=settings,
        user_repository=user_repository,
    )
    result = await auth_service.get_user_by_token(token)

    if isinstance(result, Err):
        err = result.err_value
        if isinstance(err, AccessTokenExpiredError):
            raise AccessTokenExpiredHTTPError()
        elif isinstance(err, InvalidAccessTokenError):
            raise InvalidAccessTokenHTTPError()
        else:
            raise InvalidAccessTokenHTTPError()  # fallback
    user = result.ok_value
    return user


roles = {"admin": 2, "manager": 1, "user": 0}


def get_user_with_role(role_name: str):
    async def dependency(user: User = Depends(get_current_user)):
        role = roles[role_name]
        if user.role >= role:
            return user
        raise PermissionDeniedHTTPError()

    return dependency


async def get_websocket_user(
    websocket: WebSocket,
    session: AsyncSession = Depends(create_session_depends),
) -> User:
    """
    Аутентификация пользователя через WebSocket.
    Ожидает JWT токен в query параметре 'token' или в заголовке 'Authorization'.
    """
    token = None
    
    # Пытаемся получить токен из query параметров
    query_params = dict(websocket.query_params)
    if "token" in query_params:
        token = query_params["token"]
    
    # Если токена нет в query, пытаемся получить из заголовков
    if not token:
        auth_header = websocket.headers.get("authorization")
        if auth_header and auth_header.startswith("Bearer "):
            token = auth_header[7:]  # Убираем "Bearer "
    
    # Если токен не найден
    if not token:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION, reason="Missing authentication token")
        raise WebSocketException(code=status.WS_1008_POLICY_VIOLATION, reason="Missing authentication token")
    
    # Валидируем токен
    settings = get_settings(AuthJWTSettings)
    refresh_token_repository = RefreshTokenRepository(session)
    user_repository = UserRepository(session)
    access_token_repository = AccessTokenRepository(settings)
    auth_service = AuthenticationService(
        refresh_token_repository=refresh_token_repository,
        access_token_repository=access_token_repository,
        auth_settings=settings,
        user_repository=user_repository,
    )
    
    result = await auth_service.get_user_by_token(token)
    
    if isinstance(result, Err):
        error_msg = "Invalid or expired token"
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION, reason=error_msg)
        raise WebSocketException(code=status.WS_1008_POLICY_VIOLATION, reason=error_msg)
    
    return result.ok_value


async def get_websocket_user_with_chat_access(
    websocket: WebSocket,
    chat_id: int,
    session: AsyncSession = Depends(create_session_depends),
) -> User:
    """
    Аутентификация пользователя через WebSocket с проверкой доступа к чату.
    """
    # Получаем пользователя через токен
    user = await get_websocket_user(websocket, session)
    
    # Проверяем является ли пользователь участником чата
    chat_repository = ChatRepository(session)
    is_participant = await chat_repository.is_user_participant(chat_id, user.id)
    
    if not is_participant:
        error_msg = f"Access denied to chat {chat_id}"
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION, reason=error_msg)
        raise WebSocketException(code=status.WS_1008_POLICY_VIOLATION, reason=error_msg)
    
    return user
