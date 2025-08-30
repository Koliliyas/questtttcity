from typing import assert_never
from uuid import UUID

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, BackgroundTasks, Depends, Query, status
from fastapi_pagination import Page
from fastapi_pagination.default import Params
from result import Err

from src.api import exceptions as api_exc
from src.api.modules.user import responses as user_res
from src.api.modules.user.schemas import (ChangePasswordSchema, EmailChangeSchema,
                                      UserCreateAdminSchema, UserReadSchema,
                                      UserUpdateAdminSchema, UserUpdateSchema)
from src.core.authentication import exceptions as auth_exc
from src.core.authentication.dependencies import get_user_with_role
from src.core.authorization.dependencies import require_manage_user_roles, require_view_users
from src.core.authentication.services import ChangeEmailVerificationService
from src.core.dto import EmailMessageDTO
from src.core.services import EmailSenderService
from src.core.user import exceptions as user_exc
from src.core.user.dto import (ProfileCreateDTO, UserCreateAdminDTO,
                           UserUpdateAdminDTO, UserUpdateDTO)
from src.core.user.services import UserService
from src.db.models.user import User

router = APIRouter(
    prefix="/users",
    tags=["Users"],
)


# /me
# /{id}
@router.get("/me", response_model=UserReadSchema, responses=user_res.get_me_responses)
async def get_me(user: User = Depends(get_user_with_role("user"))):
    return user


@router.get(
    "/{id}", response_model=UserReadSchema, responses=user_res.get_user_responses
)
@inject
async def get_user(
    id: UUID,
    user_service: Injected[UserService],
    user: User = Depends(get_user_with_role("user")),
):
    result = await user_service.get_user(id=id)

    if isinstance(result, Err):
        match (result.err_value,):
            case user_exc.UserNotFoundError():
                raise api_exc.UserNotFoundHTTPError()

    return result.ok_value


@router.patch(
    "/me",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=user_res.update_me_responses,
)
@inject
async def update_me(
    user_data: UserUpdateSchema,
    change_email_verification_service: Injected[ChangeEmailVerificationService],
    user_service: Injected[UserService],
    background_tasks: BackgroundTasks,
    user: User = Depends(get_user_with_role("user")),
):
    user_dto = UserUpdateDTO(
        username=user_data.username,
        first_name=user_data.first_name,
        last_name=user_data.last_name,
    )

    result = await user_service.update_user(user=user, user_dto=user_dto)

    if isinstance(result, Err):
        match result.err_value:
            case user_exc.UsernameAlreadyExistsError():
                raise api_exc.UsernameAlreadyExistsHTTPError()
            case _ as never:
                assert_never(never)

    if user_data.email and user_data.email != user.email:
        await change_email_verification_service.send_code(
            email=user_data.email,
            data={"old_email": user.email},
            background_tasks=background_tasks,
        )


@router.patch(
    "/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
@inject
async def update_user(
    id: UUID,
    user_data: UserUpdateAdminSchema,
    user_service: Injected[UserService],
    user: User = Depends(require_manage_user_roles),
):
    user_dto = UserUpdateAdminDTO(**user_data.model_dump())

    result = await user_service.get_user(id=id)

    if isinstance(result, Err):
        match (result.err_value,):
            case user_exc.UserNotFoundError():
                raise api_exc.UserNotFoundHTTPError()

    user = result.ok_value

    result = await user_service.update_user(user=user, user_dto=user_dto)

    if isinstance(result, Err):
        match result.err_value:
            case user_exc.UsernameAlreadyExistsError():
                raise api_exc.UsernameAlreadyExistsHTTPError()
            case user_exc.EmailAlreadyExistsError():
                raise api_exc.EmailAlreadyExistsHTTPError()
            case _ as never:
                assert_never(never)


@router.post(
    "/me/verify-email-change-code",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=user_res.verify_email_change_code_responses,
)
@inject
async def verify_email_change_code(
    creds: EmailChangeSchema,
    change_email_verification_service: Injected[ChangeEmailVerificationService],
    user: User = Depends(get_user_with_role("user")),
):
    result = await change_email_verification_service.verify_code(
        email=creds.email, old_user_email=user.email, code=creds.code
    )

    if isinstance(result, Err):
        match result.err_value:
            case auth_exc.InvalidEmailCodeError():
                raise api_exc.InvalidEmailCodeHTTPError()
            case auth_exc.EmailCodeExpiredError():
                raise api_exc.EmailCodeExpiredHTTPError()
            case _ as never:
                assert_never(never)


@router.post(
    "/me/change-password",
    status_code=status.HTTP_200_OK,
    responses=user_res.change_password_responses,
)
@inject
async def change_password(
    data: ChangePasswordSchema,
    user_service: Injected[UserService],
    user: User = Depends(get_user_with_role("user")),
):
    result = await user_service.change_password(
        user=user, old_password=data.old_password, new_password=data.password1
    )

    if isinstance(result, Err):
        match result.err_value:
            case auth_exc.InvalidUserCredentialsError():
                raise api_exc.InvalidUserCredentialsHTTPError
            case _ as never:
                assert_never(never)


@router.get(
    "", response_model=Page[UserReadSchema], responses=user_res.get_users_responses
)
@inject
async def get_users(
    user_service: Injected[UserService],
    search: str | None = Query(
        None, description="Search user by username and full_name."
    ),
    is_banned: bool | None = Query(False),
    params: Params = Depends(),
    user: User = Depends(require_view_users),
) -> Page[UserReadSchema]:
    return await user_service.get_users(
        params=params, search=search, is_banned=is_banned
    )


@router.post(
    "",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=user_res.create_users_responses,
)
@inject
async def create_user(
    user_data: UserCreateAdminSchema,
    user_service: Injected[UserService],
    email_sender_service: Injected[EmailSenderService],
    background_tasks: BackgroundTasks,
    user: User = Depends(require_manage_user_roles),
) -> None:
    user_dto = UserCreateAdminDTO(
        username=user_data.username,
        password=user_data.password1,
        email=user_data.email,
        first_name=user_data.first_name,
        last_name=user_data.last_name,
        role=user_data.role,
        is_verified=user_data.is_verified,
        is_active=user_data.is_active,
        can_edit_quests=user_data.can_edit_quests,
        can_lock_users=user_data.can_lock_users,
        
    )

    profile_dto = ProfileCreateDTO(avatar_url=None)
    result = await user_service.register_user(
        user_dto=user_dto, profile_dto=profile_dto
    )

    if isinstance(result, Err):
        match result.err_value:
            case user_exc.EmailAlreadyExistsError():
                raise api_exc.EmailAlreadyExistsHTTPError()
            case user_exc.UsernameAlreadyExistsError():
                raise api_exc.UsernameAlreadyExistsHTTPError()
            case _ as never:
                assert_never(never)

    message_dto = EmailMessageDTO(
        subject=f"Credentials for user: {user_dto.username}",
        recipients=[user.email, user_dto.email],
        body=f"Email: {user_dto.email}\nPassword: {user_data.password1}",
    )

    await email_sender_service.send_message(
        message_dto=message_dto, background_tasks=background_tasks
    )
