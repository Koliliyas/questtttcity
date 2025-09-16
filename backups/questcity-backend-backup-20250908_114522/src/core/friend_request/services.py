from uuid import UUID

from fastapi_pagination import Params
from result import Err, Ok
from sqlalchemy import and_, or_

from src.core import exceptions as core_exc
from src.core.friend_request import exceptions as fr_exc
from src.core.friend_request.dto import (FriendRequestCreateDTO,
                                     FriendRequestUpdateDTO)
from src.core.friend_request.repositories import FriendRequestRepository
from src.db.models.friend_request import FriendRequest


class FriendRequestService:
    def __init__(
        self,
        friend_request_repository: FriendRequestRepository,
    ):
        self._friend_request_repository = friend_request_repository

    async def get_one_between(self, user1_id: UUID, user2_id: UUID):
        friend_request = await self._friend_request_repository.get_one_between(
            user1_id=user1_id, user2_id=user2_id
        )

        if friend_request is None:
            return Err(fr_exc.FriendRequestNotFoundError())

        return Ok(friend_request)

    async def get_all_sent_for(self, id: UUID, params: Params):
        result = await self._friend_request_repository.get_all_sent_for(
            id=id, params=params
        )
        return Ok(result)

    async def get_all_received_for(self, id: UUID, params: Params):
        result = await self._friend_request_repository.get_all_received_for(
            id=id, params=params
        )
        return Ok(result)

    async def create(self, dto: FriendRequestCreateDTO):
        if dto.requester_id == dto.recipient_id:
            return Err(fr_exc.SelfFriendRequestError())
        if not await self._friend_request_repository.is_valid_for_friend_request(
            id=dto.recipient_id
        ):
            return Err(fr_exc.UserNotEligibleForFriendRequestError())
        is_friend_request_exists = await self._friend_request_repository.is_exists(
            and_(
                or_(
                    and_(
                        FriendRequest.recipient_id == dto.recipient_id,
                        FriendRequest.requester_id == dto.requester_id,
                    ),
                    and_(
                        FriendRequest.recipient_id == dto.requester_id,
                        FriendRequest.requester_id == dto.recipient_id,
                    ),
                ),
                FriendRequest.status == "sended",
            )
        )
        if is_friend_request_exists:
            return Err(fr_exc.FriendRequestAlreadyExistsError())
        await self._friend_request_repository.create_or_update(dto=dto)
        return Ok(1)

    async def delete(self, friend_request_id: int, user_id: UUID):
        friend_request = await self._friend_request_repository.get(id=friend_request_id)
        print(friend_request.requester_id, friend_request.recipient_id)
        if friend_request is None:
            return Err(fr_exc.FriendRequestNotFoundError())

        if friend_request.requester_id == user_id:
            return Err(core_exc.PermissionDeniedError())

        await self._friend_request_repository.delete(obj=friend_request)
        return Ok(friend_request)

    async def update(
        self, friend_request_id: int, user_id: UUID, dto: FriendRequestUpdateDTO
    ):
        friend_request = await self._friend_request_repository.get(id=friend_request_id)

        if friend_request is None:
            return Err(fr_exc.FriendRequestNotFoundError())

        if friend_request.requester_id == user_id:
            return Err(core_exc.PermissionDeniedError())

        friend_request = await self._friend_request_repository.update(
            obj=friend_request, dto=dto
        )

        return Ok(friend_request)
