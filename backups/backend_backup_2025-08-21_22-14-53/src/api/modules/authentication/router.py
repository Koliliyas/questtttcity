from typing import Annotated, assert_never

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, BackgroundTasks, Form, status
from result import Err

from src.api.exceptions import (EmailAlreadyExistsHTTPError,
                            EmailCodeExpiredHTTPError, InactiveUserHTTPError,
                            InvalidEmailCodeHTTPError,
                            InvalidRefreshTokeHTTPError,
                            InvalidResetPasswordTokenHTTPError,
                            InvalidUserCredentialsHTTPError,
                            RefreshTokenExpiredHTTPError,
                            UnverifiedUserHTTPError,
                            UsernameAlreadyExistsHTTPError,
                            UserNotFoundForEmailHTTPError)
from src.api.modules.authentication.responses import (
    login_responses, logout_responses, refresh_token_responses,
    register_responses, reset_password_by_token_responses,
    reset_password_responses, verify_register_responses,
    verify_reset_password_responses)
from src.api.modules.authentication.schemas import (EmailResetPasswordSchema,
                                                RefreshTokenDestroy,
                                                ResetPasswordSchema,
                                                ResetPasswordTokenReadSchema,
                                                TokensReadSchema,
                                                TokensRefreshSchema,
                                                VerifyEmailSchema)
from src.api.modules.user.schemas import UserCreateSchema
from src.core.authentication.exceptions import (EmailCodeExpiredError,
                                            InactiveUserError,
                                            InvalidEmailCodeError,
                                            InvalidRefreshTokeError,
                                            InvalidResetPasswordTokenError,
                                            InvalidUserCredentialsError,
                                            RefreshTokenExpiredError,
                                            ResetPasswordTokenExpiredError,
                                            UnverifiedUserError,
                                            UserNotFoundForEmailError)
from src.core.authentication.services import (
    AuthenticationService, RegistrationEmailVerificationService,
    ResetPasswordEmailVerificationService)
from src.core.user.dto import ProfileCreateDTO, UserCreateDTO
from src.core.user.exceptions import (EmailAlreadyExistsError,
                                  UsernameAlreadyExistsError)
from src.core.user.services import UserService

router = APIRouter(
    prefix="/auth",
    tags=["Auth"],
)


@router.post(
    "/refresh-token", response_model=TokensReadSchema, responses=refresh_token_responses
)
@inject
async def refresh_token(
    tokens: TokensRefreshSchema, auth_service: Injected[AuthenticationService]
):
    # TODO: divide get_token_pare into verify_token and get_token_pare

    result = await auth_service.get_token_pare(old_refresh_token=tokens.refresh_token)

    if isinstance(result, Err):
        match result.err_value:
            case RefreshTokenExpiredError():
                raise RefreshTokenExpiredHTTPError()
            case InvalidRefreshTokeError():
                raise InvalidRefreshTokeHTTPError()
            case _ as never:
                assert_never(never)

    return TokensReadSchema(**result.ok_value)


@router.post("/login", response_model=TokensReadSchema, responses=login_responses)
@inject
async def login(
    login: Annotated[str, Form()],
    password: Annotated[str, Form()],
    auth_service: Injected[AuthenticationService],
):
    result = await auth_service.validate_auth_user(login=login, password=password)

    if isinstance(result, Err):
        match result.err_value:
            case InvalidUserCredentialsError():
                raise InvalidUserCredentialsHTTPError()
            case InactiveUserError():
                raise InactiveUserHTTPError()
            case UnverifiedUserError():
                raise UnverifiedUserHTTPError()
            case _ as never:
                assert_never(never)
    user = result.ok_value
    result = await auth_service.get_token_pare(user=user)

    tokens = result.ok_value

    return TokensReadSchema(**tokens)


@router.post(
    "/register",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=register_responses,
)
@inject
async def register(
    user: UserCreateSchema,
    user_service: Injected[UserService],
) -> None:
    user_dto = UserCreateDTO(
        username=user.username,
        password=user.password1,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
    )

    profile_dto = ProfileCreateDTO(avatar_url=None)
    result = await user_service.register_user(
        user_dto=user_dto, profile_dto=profile_dto
    )

    if isinstance(result, Err):
        match result.err_value:
            case EmailAlreadyExistsError():
                raise EmailAlreadyExistsHTTPError()
            case UsernameAlreadyExistsError():
                raise UsernameAlreadyExistsHTTPError
            case _ as never:
                assert_never(never)

    # TODO: Email verification временно отключена
    # await email_verification_service.send_code(
    #     email=user_dto.email,
    #     background_tasks=background_tasks,
    # )


@router.post(
    "/register/verify-code",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=verify_register_responses,
)
@inject
async def verify_register(
    creds: VerifyEmailSchema,
    user_service: Injected[UserService],
):
    # TODO: Email verification временно отключена - принимаем любой код
    # Просто устанавливаем пользователя как verified
    user = await user_service._user_repository.get_by_email(creds.email)
    if user:
        await user_service._user_repository.update(
            creds.email, 
            {'is_verified': True}
        )
    # Всегда возвращаем успех


@router.post(
    "/logout", status_code=status.HTTP_204_NO_CONTENT, responses=logout_responses
)
@inject
async def logout(
    tokens: RefreshTokenDestroy, auth_service: Injected[AuthenticationService]
):
    result = await auth_service.destroy_refresh_token(
        refresh_token=tokens.refresh_token
    )

    if isinstance(result, Err):
        match result.err_value:
            case InvalidRefreshTokeError():
                raise InvalidRefreshTokeHTTPError()
            case _ as never:
                assert_never(never)


@router.post(
    "/reset-password",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=reset_password_responses,
)
@inject
async def reset_password(
    email: EmailResetPasswordSchema,
    reset_email_verification_password_service: Injected[
        ResetPasswordEmailVerificationService
    ],
    background_tasks: BackgroundTasks,
):
    result = await reset_email_verification_password_service.send_code(
        email=email.email,
        background_tasks=background_tasks,
    )

    if isinstance(result, Err):
        match result.err_value:
            case UserNotFoundForEmailError():
                raise UserNotFoundForEmailHTTPError()
            case InactiveUserError():
                raise InactiveUserHTTPError()
            case UnverifiedUserError():
                raise UnverifiedUserHTTPError()
            case _ as never:
                assert_never(never)


@router.post(
    "/reset-password/verify-code",
    status_code=status.HTTP_200_OK,
    response_model=ResetPasswordTokenReadSchema,
    responses=verify_reset_password_responses,
)
@inject
async def verify_reset_password(
    creds: VerifyEmailSchema,
    reset_email_verification_password_service: Injected[
        ResetPasswordEmailVerificationService
    ],
):
    result = await reset_email_verification_password_service.verify_code(
        email=creds.email, code=creds.code
    )

    if isinstance(result, Err):
        match result.err_value:
            case InvalidEmailCodeError():
                raise InvalidEmailCodeHTTPError()
            case EmailCodeExpiredError():
                raise EmailCodeExpiredHTTPError()
            case _ as never:
                assert_never(never)

    token = result.ok_value

    return ResetPasswordTokenReadSchema(token=token)


@router.post(
    "/reset-password/{token}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=reset_password_by_token_responses,
)
@inject
async def reset_password_by_token(
    token: str,
    creds: ResetPasswordSchema,
    reset_email_verification_password_service: Injected[
        ResetPasswordEmailVerificationService
    ],
    user_service: Injected[UserService],
):
    result = await reset_email_verification_password_service.verify_token(token=token)

    if isinstance(result, Err):
        match result.err_value:
            case InvalidResetPasswordTokenError():
                raise InvalidResetPasswordTokenHTTPError()
            case ResetPasswordTokenExpiredError():
                raise ResetPasswordTokenExpiredError()
            case _ as never:
                assert_never(never)

    email = result.ok_value
    password = creds.password1

    result = await user_service.reset_password(email=email, password=password)

    if isinstance(result, Err):
        match result.err_value:
            case UserNotFoundForEmailError():
                raise UserNotFoundForEmailHTTPError()
