from typing import assert_never

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from result import Err
from sqlalchemy.ext.asyncio import AsyncSession

from api.exceptions import (AccessTokenExpiredHTTPError,
                            InvalidAccessTokenHTTPError,
                            MissingAccessTokenHTTPError,
                            PermissionDeniedHTTPError)
from core.authentication.exceptions import (AccessTokenExpiredError,
                                            InvalidAccessTokenError)
from core.authentication.repositories import (AccessTokenRepository,
                                              RefreshTokenRepository)
from core.authentication.services import AuthenticationService
from core.user.repositories import UserRepository
from db.dependencies import create_session_depends
from db.models.user import User
from settings import AuthJWTSettings, get_settings

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
        match result.err_value:
            case AccessTokenExpiredError():
                raise AccessTokenExpiredHTTPError()
            case InvalidAccessTokenError():
                raise InvalidAccessTokenHTTPError()
            case _ as never:
                assert_never(never)
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
