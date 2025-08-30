from uuid import UUID

from result import Err, Ok

from src.core.favorite.dto import BaseFavoriteDTO
from src.core.favorite.exceptions import (FavoriteAlreadyExistsError,
                                      FavoriteNotFoundError)
from src.core.favorite.repositories import FavoriteRepository
from src.core.quest.exceptions import QuestNotFoundException
from src.core.quest.repositories import QuestRepository
from src.db.models.favorite import Favorite


class FavoriteService:
    def __init__(
        self, favorite_repository: FavoriteRepository, quest_repository: QuestRepository
    ):
        self._favorite_repository = favorite_repository
        self._quest_repository = quest_repository

    async def create(self, dto: BaseFavoriteDTO):
        if not await self._quest_repository.get_by_oid(dto.quest_id):
            return Err(QuestNotFoundException())

        if await self._favorite_repository.is_exists(
            Favorite.quest_id == dto.quest_id, Favorite.user_id == dto.user_id
        ):
            return Err(FavoriteAlreadyExistsError())

        await self._favorite_repository.create(dto=dto)

        return Ok(1)

    async def get_all(self, user_id: UUID):
        result = await self._favorite_repository.get_all(Favorite.user_id == user_id)
        return Ok(result)

    async def delete(self, dto: BaseFavoriteDTO):
        if not await self._favorite_repository.is_exists(
            Favorite.quest_id == dto.quest_id, Favorite.user_id == dto.user_id
        ):
            return Err(FavoriteNotFoundError())

        await self._favorite_repository.delete(dto=dto)

        return Ok(1)
