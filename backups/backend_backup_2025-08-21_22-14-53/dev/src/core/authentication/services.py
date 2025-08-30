from datetime import datetime, timedelta
from typing import Dict

from fastapi import BackgroundTasks
from fastapi_mail import FastMail, MessageSchema, MessageType
from result import Err, Ok

from core.authentication import exceptions as auth_exc
from core.authentication import utils as auth_utils
from core.authentication.repositories import (AccessTokenRepository,
                                              EmailVerificationCodeRepository,
                                              RefreshTokenRepository,
                                              ResetPasswordTokenRepository)
from core.user.repositories import UserRepository
from db.models.user import User
from settings import AuthJWTSettings, EmailVerificationSettings


class AuthenticationService:
    def __init__(
        self,
        refresh_token_repository: RefreshTokenRepository,
        access_token_repository: AccessTokenRepository,
        auth_settings: AuthJWTSettings,
        user_repository: UserRepository,
    ):
        self._refresh_token_repository = refresh_token_repository
        self._access_token_repository = access_token_repository
        self._auth_settings = auth_settings
        self._user_repository = user_repository

    async def get_token_pare(
        self, user: User | None = None, old_refresh_token: str | None = None
    ) -> Dict[str, str]:
        if old_refresh_token:
            result = await self._refresh_token_repository.get(old_refresh_token)
            if not result:
                return Err(auth_exc.InvalidRefreshTokeError())
            token, user = result
            if datetime.utcnow() - token.created_at > timedelta(
                days=self._auth_settings.refresh_token_expire_days
            ):
                return Err(auth_exc.RefreshTokenExpiredError())
            await self._refresh_token_repository.delete(old_refresh_token)

        payload = {"sub": str(user.id)}

        access_token = self._access_token_repository.create(payload=payload)
        refresh_token = await self._refresh_token_repository.create(user_id=user.id)

        return Ok({"access_token": access_token, "refresh_token": refresh_token.id})

    async def get_user_by_token(self, token: str) -> User | None:
        result = self._access_token_repository.verify_token(token)
        if isinstance(result, Err):
            return result
        result = await self._user_repository.get_by_pk(id_=result.ok_value.get("sub"))
        if not result:
            return Err(auth_exc.InvalidAccessTokenError())
        return Ok(result)

    async def destroy_refresh_token(self, refresh_token: str):
        await self._refresh_token_repository.delete(refresh_token)

    async def validate_auth_user(self, login: str, password: str):
        if "@" not in login:
            user = await self._user_repository.get_by_username(username=login)
        else:
            user = await self._user_repository.get_by_email(email=login)
        if not user or not auth_utils.validate_password(
            password=password, hashed_password=user.password
        ):
            return Err(auth_exc.InvalidUserCredentialsError())

        if not user.is_active:
            return Err(auth_exc.InactiveUserError())
        if not user.is_verified:
            return Err(auth_exc.UnverifiedUserError())
        return Ok(user)


class ChangeEmailVerificationService:
    def __init__(
        self,
        code_repository: EmailVerificationCodeRepository,
        user_repository: UserRepository,
        settings: EmailVerificationSettings,
        mail_service: FastMail,
    ) -> None:
        self._code_repository = code_repository
        self._user_repository = user_repository
        self._settings = settings
        self._mail_service = mail_service

    async def send_code(
        self, email: str, data: dict, background_tasks: BackgroundTasks
    ):
        code = await self._code_repository.create(email=email, data=data)

        message = MessageSchema(
            subject="Email verification for change email.",
            recipients=[email],
            body=f"Your code is {code.code}",
            subtype=MessageType.plain,
        )

        background_tasks.add_task(self._mail_service.send_message, message)

        return Ok(1)

    async def verify_code(self, email: str, old_user_email: str, code: int):
        result = await self._code_repository.get(email=email, code=code)
        code = result
        if not code or code.optional_data.get("old_email") != old_user_email:
            return Err(auth_exc.InvalidEmailCodeError())
        if datetime.utcnow() - code.created_at > timedelta(
            minutes=self._settings.code_expire_minutes
        ):
            await self._code_repository.delete(email=email, code=code.code)
            return Err(auth_exc.EmailCodeExpiredError())

        await self._code_repository.delete(email=email, code=code.code)

        user_update_fields = {"email": email}

        await self._user_repository.update(
            email=old_user_email, fields_to_update=user_update_fields
        )

        return Ok(1)


class RegistrationEmailVerificationService:
    def __init__(
        self,
        user_repository: UserRepository,
        code_repository: EmailVerificationCodeRepository,
        mail_service: FastMail,
        settings: EmailVerificationSettings,
    ) -> None:
        self._user_repository = user_repository
        self._code_repository = code_repository
        self._mail_service = mail_service
        self._settings = settings

    async def send_code(self, email: str, background_tasks: BackgroundTasks):
        code = await self._code_repository.create(email)

        message = MessageSchema(
            subject="Email verification for registration",
            recipients=[email],
            body=f"Your code is {code.code}",
            subtype=MessageType.plain,
        )

        background_tasks.add_task(self._mail_service.send_message, message)

        return Ok(1)

    async def verify_code(self, email: str, code: int):
        result = await self._code_repository.get(email=email, code=code)
        if not result:
            return Err(auth_exc.InvalidEmailCodeError())
        code = result
        if datetime.utcnow() - code.created_at > timedelta(
            minutes=self._settings.code_expire_minutes
        ):
            await self._code_repository.delete(email=email, code=code.code)
            return Err(auth_exc.EmailCodeExpiredError())

        await self._code_repository.delete(email=email, code=code.code)

        result = await self._user_repository.update(
            email=email, fields_to_update={"is_verified": True}
        )

        if not result:
            return Err(auth_exc.UserNotFoundForEmailError())

        return Ok(1)


class ResetPasswordEmailVerificationService:
    def __init__(
        self,
        token_repository: ResetPasswordTokenRepository,
        user_repository: UserRepository,
        code_repository: EmailVerificationCodeRepository,
        mail_service: FastMail,
        settings: EmailVerificationSettings,
    ) -> None:
        self._token_repository = token_repository
        self._user_repository = user_repository
        self._code_repository = code_repository
        self._mail_service = mail_service
        self._settings = settings

    async def send_code(self, email: str, background_tasks: BackgroundTasks):
        user = await self._user_repository.get_by_email(email=email)

        if not user:
            return Err(auth_exc.UserNotFoundForEmailError())
        if not user.is_active:
            return Err(auth_exc.InactiveUserError())
        if not user.is_verified:
            return Err(auth_exc.UnverifiedUserError())

        code = await self._code_repository.create(email)

        message = MessageSchema(
            subject="Password reset",
            recipients=[email],
            body=f"Your code is {code.code}",
            subtype=MessageType.plain,
        )

        background_tasks.add_task(self._mail_service.send_message, message)

        return Ok(1)

    async def verify_code(self, email: str, code: int):
        result = await self._code_repository.get(email=email, code=code)
        if not result:
            return Err(auth_exc.InvalidEmailCodeError())
        code = result
        if datetime.utcnow() - code.created_at > timedelta(
            minutes=self._settings.code_expire_minutes
        ):
            return Err(auth_exc.EmailCodeExpiredError())

        await self._code_repository.delete(email=email, code=code.code)

        token = await self._token_repository.create(email=email)
        return Ok(token.id)

    async def verify_token(self, token: str) -> str:
        result = await self._token_repository.get(pk=token)

        if not result:
            return Err(auth_exc.InvalidResetPasswordTokenError())

        # TODO: Create a function to check if the instance is expired

        token = result

        if datetime.utcnow() - token.created_at > timedelta(
            minutes=self._settings.code_expire_minutes
        ):
            return Err(auth_exc.ResetPasswordTokenExpiredError())

        await self._token_repository.delete(pk=token.id)

        email = token.email

        return Ok(email)
