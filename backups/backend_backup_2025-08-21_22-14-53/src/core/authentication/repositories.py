from datetime import datetime, timedelta
from typing import Dict, Optional
from uuid import UUID

from jose import jwt
from jose.exceptions import ExpiredSignatureError, JWTError
from result import Err, Ok, Result
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload  # Добавляем импорт для eager loading

from src.core.authentication.exceptions import (AccessTokenExpiredError,
                                            InvalidAccessTokenError)
from src.core.authentication.jwt_keys import JWTKeysError, load_and_validate_key
from src.db.models import RefreshToken
from src.db.models.authentication import EmailVerificationCode, ResetPasswordToken
from src.db.models.user import User
from src.settings import AuthJWTSettings, EmailVerificationSettings


class RefreshTokenRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def get(self, pk: str) -> RefreshToken | None:
        query = (
            select(RefreshToken)
            .options(selectinload(RefreshToken.user))  # Eager loading пользователя
            .where(RefreshToken.id == pk)
        )
        result = await self._session.execute(query)
        return result.scalar_one_or_none()

    async def create(self, user_id: UUID) -> RefreshToken:
        token = RefreshToken(user_id=user_id)
        self._session.add(token)
        await self._session.flush()
        return token

    async def delete(self, token: str) -> None:
        await self._session.execute(
            delete(RefreshToken).where(RefreshToken.id == token)
        )
        await self._session.flush()


class AccessTokenRepository:
    def __init__(self, settings: AuthJWTSettings):
        self._settings = settings

    def create(self, payload: dict) -> str:
        try:
            private_key = load_and_validate_key(self._settings.private_key_path, is_private=True)
        except JWTKeysError as e:
            raise AccessTokenExpiredError(f"Ошибка загрузки приватного ключа JWT: {e}")
        
        algorithm = self._settings.algorithm
        expire_minutes = self._settings.access_token_expire_minutes
        to_encode = payload.copy()
        now = datetime.utcnow()
        expire = now + timedelta(minutes=expire_minutes)
        to_encode.update(exp=expire, iat=now)
        encoded = jwt.encode(
            claims=to_encode,
            key=private_key,
            algorithm=algorithm,
        )
        return str(encoded)

    def verify_token(self, token: str, check_exp: bool = True) -> Result[Dict[str, str], InvalidAccessTokenError | AccessTokenExpiredError]:
        try:
            public_key: str = load_and_validate_key(self._settings.public_key_path, is_private=False)
        except JWTKeysError as e:
            return Err(InvalidAccessTokenError(f"Ошибка загрузки публичного ключа JWT: {e}"))
        
        algorithm: str = self._settings.algorithm
        try:
            payload = jwt.decode(
                token,
                public_key,
                algorithms=[algorithm],
                options={"verify_exp": check_exp},
            )
        except ExpiredSignatureError:
            return Err(AccessTokenExpiredError())
        except JWTError:
            return Err(InvalidAccessTokenError())
        return Ok(payload)


class EmailVerificationCodeRepository:
    def __init__(self, session: AsyncSession, settings: EmailVerificationSettings):
        self._settings = settings
        self._session = session

    async def create(self, email: str, data: Optional[dict] = None) -> EmailVerificationCode:
        code = EmailVerificationCode(email=email)
        if data is not None:
            code.optional_data = data
        self._session.add(code)
        await self._session.flush()
        return code

    async def get(self, email: str, code: int) -> EmailVerificationCode | None:
        return await self._session.get(EmailVerificationCode, (code, email))

    async def delete(self, email: str, code: int) -> None:
        await self._session.execute(
            delete(EmailVerificationCode).where(
                EmailVerificationCode.email == email, EmailVerificationCode.code == code
            )
        )
        await self._session.flush()


class ResetPasswordTokenRepository:
    def __init__(self, session: AsyncSession, settings: EmailVerificationSettings):
        self._session = session
        self._settings = settings

    async def get(self, pk: str) -> ResetPasswordToken | None:
        return await self._session.get(ResetPasswordToken, pk)

    async def create(self, email: str) -> ResetPasswordToken:
        token = ResetPasswordToken(email=email)
        self._session.add(token)
        await self._session.flush()
        return token

    async def delete(self, pk: str) -> None:
        await self._session.execute(
            delete(ResetPasswordToken).where(ResetPasswordToken.id == pk)
        )
        await self._session.flush()
