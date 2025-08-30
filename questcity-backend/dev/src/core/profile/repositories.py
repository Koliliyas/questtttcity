from sqlalchemy import update
from sqlalchemy.ext.asyncio import AsyncSession

from core.user.dto import ProfileCreateDTO
from db.models.user import Profile


class ProfileRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def get(self, id_: int) -> Profile | None:
        return await self._session.get(Profile, id_)

    async def create(self, dto: ProfileCreateDTO) -> Profile:
        model = Profile(avatar_url=dto.avatar_url)
        self._session.add(model)
        await self._session.flush()
        return model

    async def update(self, id_: int, fields_to_update: dict):
        await self._session.execute(
            update(Profile).where(Profile.id == id_).values(**fields_to_update)
        )
