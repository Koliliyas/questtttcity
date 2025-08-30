from dataclasses import asdict
from typing import Sequence
from uuid import UUID

from fastapi_pagination import Params
from fastapi_pagination.ext.sqlalchemy import paginate
from sqlalchemy import asc, desc, exists, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload

from core.authentication import utils as auth_utils
from core.search import FuzzySearchService
from core.user.dto import UserCreateAdminDTO, UserCreateDTO
from db.models.user import User


class UserRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def get_all(self, is_banned: bool = False) -> Sequence[User]:
        result = await self._session.execute(
            select(User).where(User.is_active.is_(not is_banned))
        )
        return result.unique().scalars().all()

    async def get_users(
        self, params: Params, search_query: str | None, is_banned: bool
    ):
        if search_query:
            search = FuzzySearchService(
                User.username, User.full_name, similarity_limit=0.1, model=User
            )
            await search.set_similarity_limit(self._session)
            query = (
                search(
                    search_query, additional_where=[User.is_active == (not is_banned)]
                )
            ).options(joinedload(User.profile))
        else:
            query = query = (
                select(User)
                .where(User.is_active == (not is_banned))
                .options(joinedload(User.profile))
            )

        query = query.order_by(desc(User.role), asc(User.created_at))
        result = await paginate(
            self._session, query=query, params=params, subquery_count=True
        )
        return result

    async def get_by_pk(self, id_: UUID) -> User | None:
        query = select(User).where(User.id == id_).options(joinedload(User.profile))
        result = await self._session.execute(query)
        return result.unique().scalar_one_or_none()

    # TODO: refactor is_email_used, is_username_used

    async def is_email_used(self, email: str) -> bool:
        query = await self._session.execute(select(exists().where(User.email == email)))
        return query.first()[0]

    async def is_username_used(self, username: str) -> bool:
        query = await self._session.execute(
            select(exists().where(User.username == username))
        )
        return query.first()[0]

    async def get_by_email(self, email: str) -> User | None:
        query = await self._session.execute(
            select(User).where(User.email == email).options(joinedload(User.profile))
        )
        return query.unique().scalar_one_or_none()

    async def get_by_username(self, username: str) -> User | None:
        query = await self._session.execute(
            select(User)
            .where(User.username == username)
            .options(joinedload(User.profile))
        )
        return query.unique().scalar_one_or_none()

    async def create(self, dto: UserCreateDTO | UserCreateAdminDTO) -> User:
        dto.password = str(auth_utils.hash_password(dto.password))
        model = User(**asdict(dto))
        self._session.add(model)
        await self._session.flush()
        return model

    # TODO: remove set_new_password and make update on User.id

    async def set_new_password(self, email: str, password: str):
        password = str(auth_utils.hash_password(password))
        result = await self._session.execute(
            update(User)
            .where(User.email == email)
            .values(password=password)
            .returning(User.id)
        )
        return result.fetchall()

    async def update(self, email: str, fields_to_update: dict):
        result = await self._session.execute(
            update(User)
            .where(User.email == email)
            .values(**fields_to_update)
            .returning(User)
        )

        return result.fetchall()
