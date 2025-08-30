from uuid import UUID

from fastapi_pagination import Params
from result import Err, Ok

from core.friend import exceptions as f_exc
from core.friend.dto import FriendCreateDTO
from core.friend.repositories import FriendRepository


class FriendService:
    def __init__(self, friend_repository: FriendRepository):
        self._friend_repository = friend_repository

    async def get_all_for(self, id: UUID, search_query: str, params: Params):
        result = await self._friend_repository.get_all_for(
            id=id, search_query=search_query, params=params
        )
        return Ok(result)

    async def create(self, dto: FriendCreateDTO):
        if not await self._friend_repository.is_user_valid_for_friend(id=dto.friend_id):
            return Err(f_exc.UserNotEligibleForFriendError())

        if await self._friend_repository.is_exists(
            user1_id=dto.me_id, user2_id=dto.friend_id
        ):
            return Err(f_exc.FriendshipAlreadyExistsError())

        result = await self._friend_repository.create(dto=dto)
        return Ok(1)

    async def delete(self, user_id: UUID, friend_id: UUID):
        result = list(
            await self._friend_repository.get_one(user1_id=user_id, user2_id=friend_id)
        )

        if len(result) != 2:
            return Err(f_exc.FriendshipNotFoundError())

        await self._friend_repository.delete(*result)

        return Ok(result)
