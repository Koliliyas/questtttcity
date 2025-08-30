from uuid import UUID

from fastapi_pagination import Params
from result import Err, Ok

from core.authentication import exceptions as auth_exc
from core.authentication import utils as auth_utils
from core.authentication.exceptions import UserNotFoundForEmailError
from core.profile.repositories import ProfileRepository
from core.user.dto import (ProfileCreateDTO, UserCreateAdminDTO, UserCreateDTO,
                           UserUpdateAdminDTO, UserUpdateDTO)
from core.user.exceptions import (EmailAlreadyExistsError,
                                  UsernameAlreadyExistsError,
                                  UserNotFoundError)
from core.user.repositories import UserRepository
from db.models.user import User


class UserService:
    def __init__(
        self,
        user_repository: UserRepository,
        profile_repository: ProfileRepository,
    ):
        self._user_repository = user_repository
        self._profile_repository = profile_repository

    async def register_user(
        self,
        user_dto: UserCreateDTO | UserCreateAdminDTO,
        profile_dto: ProfileCreateDTO,
    ) -> User:
        if await self._user_repository.is_email_used(email=user_dto.email):
            return Err(EmailAlreadyExistsError())

        if await self._user_repository.is_username_used(username=user_dto.username):
            return Err(UsernameAlreadyExistsError())

        profile = await self._profile_repository.create(dto=profile_dto)
        user_dto.profile_id = profile.id
        user = await self._user_repository.create(dto=user_dto)

        return Ok(user)

    async def reset_password(self, email: str, password: str):
        result = await self._user_repository.set_new_password(
            email=email, password=password
        )

        if not result:
            return Err(UserNotFoundForEmailError())
        return Ok(1)

    async def change_password(self, user: User, old_password: str, new_password: str):
        if not auth_utils.validate_password(
            password=old_password, hashed_password=user.password
        ):
            return Err(auth_exc.InvalidUserCredentialsError())

        await self._user_repository.set_new_password(
            email=user.email, password=new_password
        )
        return Ok(1)

    async def update_user(
        self, user: User, user_dto: UserUpdateDTO | UserUpdateAdminDTO
    ):
        if user_dto.username:
            if (
                user_dto.username != user.username
                and await self._user_repository.is_username_used(
                    username=user_dto.username
                )
            ):
                return Err(UsernameAlreadyExistsError())
        if isinstance(user_dto, UserUpdateAdminDTO):
            if user_dto != user.email and await self._user_repository.is_email_used(
                email=user_dto.email
            ):
                return Err(EmailAlreadyExistsError())
            if user_dto.password:
                user_dto.password = str(auth_utils.hash_password(user_dto.password))

        user_update_fields = user_dto.get_non_none_fields()

        await self._user_repository.update(
            email=user.email, fields_to_update=user_update_fields
        )
        return Ok(1)

    async def get_users(self, params: Params, search: str, is_banned: bool):
        return await self._user_repository.get_users(
            params=params, search_query=search, is_banned=is_banned
        )

    async def get_staff_emails(self) -> list[str]:
        users = await self._user_repository.get_all()
        return [user.email for user in users if user.role >= 1]

    async def get_user(self, id: UUID) -> User:
        result = await self._user_repository.get_by_pk(id_=id)
        if not result:
            return Err(UserNotFoundError())
        return Ok(result)
