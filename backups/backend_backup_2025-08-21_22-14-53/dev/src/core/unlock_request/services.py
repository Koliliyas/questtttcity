from fastapi_pagination import Params
from result import Err, Ok

from api.modules.unlock_request.filters import UnlockRequestFilter
from core.unlock_request import exceptions as ur_exc
from core.unlock_request.dto import (UnlockRequestCreateDTO,
                                     UnlockRequestUpdateDTO)
from core.unlock_request.repositories import UnlockRequestRepository
from core.user.exceptions import UserNotFoundError
from core.user.repositories import UserRepository


class UnlockRequestService:
    def __init__(
        self, unlock_request: UnlockRequestRepository, user_repository: UserRepository
    ):
        self._unlock_request_repository = unlock_request
        self._user_repository = user_repository

    async def create_unlock_request(self, unlock_request_dto: UnlockRequestCreateDTO):
        if not await self._user_repository.is_email_used(
            email=unlock_request_dto.email
        ):
            return Err(UserNotFoundError())
        if await self._unlock_request_repository.has_active_status(
            email=unlock_request_dto.email
        ):
            return Err(ur_exc.ActiveUserError())

        if await self._unlock_request_repository.has_pending_unlock_request(
            email=unlock_request_dto.email
        ):
            return Err(ur_exc.PendingUnlockRequestExistsError())

        await self._unlock_request_repository.create(
            unlock_request_dto=unlock_request_dto
        )

        return Ok(1)

    async def get_unlock_requests(
        self, filter: UnlockRequestFilter, pagination_params: Params
    ):
        result = await self._unlock_request_repository.get_all(
            filter=filter, pagination_params=pagination_params
        )
        return Ok(result)

    async def get_unlock_request(self, id: int):
        result = await self._unlock_request_repository.get_one(id_=id)
        if not result:
            return Err(ur_exc.UnlockRequestNotFoundError())
        return Ok(result)

    async def update_unlock_request(
        self, id_: int, unlock_request_dto: UnlockRequestUpdateDTO
    ):
        result = await self._unlock_request_repository.update(
            id_=id_, dto=unlock_request_dto
        )

        if not result:
            return Err(ur_exc.UnlockRequestNotFoundError())

        if unlock_request_dto.status == "approved":
            unlock_request = await self._unlock_request_repository.get_one(id_=id_)
            user = await self._user_repository.get_by_email(email=unlock_request.email)
            user.is_active = True

        return Ok(1)
