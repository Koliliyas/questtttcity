from dataclasses import asdict

from sqlalchemy import delete, exists, select
from sqlalchemy.ext.asyncio import AsyncSession

from core.favorite.dto import BaseFavoriteDTO
from db.models.favorite import Favorite


class FavoriteRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def is_exists(self, *conditions):
        subquery = select(Favorite.id).where(*conditions).limit(1)
        stmt = select(exists(subquery))
        result = await self._session.execute(stmt)
        return result.scalar()

    async def create(self, dto: BaseFavoriteDTO):
        data = asdict(dto)
        result = Favorite(**data)
        self._session.add(result)
        await self._session.flush()
        return result

    async def get_all(self, *conditions):
        stmt = select(Favorite).where(*conditions)
        result = await self._session.execute(stmt)
        return result.scalars()

    async def delete(self, dto: BaseFavoriteDTO):
        stmt = delete(Favorite).where(
            Favorite.quest_id == dto.quest_id, Favorite.user_id == dto.user_id
        )
        result = await self._session.execute(stmt)
        return result
