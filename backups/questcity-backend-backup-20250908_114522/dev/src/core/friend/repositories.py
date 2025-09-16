from uuid import UUID

from fastapi_pagination import Params
from fastapi_pagination.ext.sqlalchemy import paginate
from sqlalchemy import exists, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from core.friend.dto import FriendCreateDTO
from core.search import FuzzySearchService
from db.models.friend import Friend
from db.models.user import User


class FriendRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def create(self, dto: FriendCreateDTO):
        obj1 = Friend(user_id=dto.me_id, friend_id=dto.friend_id)
        obj2 = Friend(user_id=dto.friend_id, friend_id=dto.me_id)

        self._session.add_all([obj1, obj2])
        await self._session.flush()

    async def get_all_for(self, id: UUID, search_query: str, params: Params):
        if search_query:
            search = FuzzySearchService(
                User.username, User.full_name, similarity_limit=0.1, model=User
            )
            await search.set_similarity_limit(self._session)
            query = (
                search(term=search_query)
                .join(Friend, (Friend.user_id == id) & (Friend.friend_id == User.id))
                .where(User.id != id)
            )
        else:
            query = (
                select(User)
                .join(Friend, (Friend.user_id == id) & (Friend.friend_id == User.id))
                .where(User.id != id)
            )

        query = query.where(User.is_active.is_(True))

        result = await paginate(
            self._session, query=query, params=params, subquery_count=True
        )
        return result

    async def is_user_valid_for_friend(self, id: UUID):
        stmt = select(
            exists().where(
                User.id == id,
                User.is_active.is_(True),
                User.is_verified.is_(True),
            )
        ).select_from(User)
        result = await self._session.execute(stmt)
        return result.scalar()

    async def is_exists(self, user1_id: UUID, user2_id: UUID):
        subquery = (
            select(Friend.id)
            .where(Friend.user_id == user1_id, Friend.friend_id == user2_id)
            .limit(1)
        )
        stmt = select(exists(subquery))
        result = await self._session.execute(stmt)
        return result.scalar()

    async def get_one(self, user1_id: UUID, user2_id: UUID):
        stmt = select(Friend).where(
            or_(
                Friend.user_id == user1_id and Friend.friend_id == user2_id,
                Friend.user_id == user2_id and Friend.friend_id == user1_id,
            )
        )

        result = await self._session.execute(stmt)
        return result.scalars()

    async def delete(self, user1_obj: Friend, user2_obj: Friend):
        await self._session.delete(user1_obj)
        await self._session.delete(user2_obj)
