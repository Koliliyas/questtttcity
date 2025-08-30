from dataclasses import asdict
from uuid import UUID

from fastapi_pagination import Params
from fastapi_pagination.ext.sqlalchemy import paginate
from sqlalchemy import exists, or_, select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.friend_request.dto import (FriendRequestCreateDTO,
                                     FriendRequestUpdateDTO)
from src.db.models.friend_request import FriendRequest
from src.db.models.user import User


class FriendRequestRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def create_or_update(self, dto: FriendRequestCreateDTO):
        stmt = (
            insert(FriendRequest)
            .values(
                requester_id=dto.requester_id,
                recipient_id=dto.recipient_id,
                status="sended",
            )
            .on_conflict_do_update(
                index_elements=["requester_id", "recipient_id"],  # Уникальные поля
                set_={"friend_request_status_enum": "sended"},  # Поля для обновления
            )
        )
        await self._session.execute(stmt)

    async def get_all_received_for(self, id: UUID, params: Params):
        query = (
            select(
                FriendRequest.id,
                FriendRequest.requester_id,
                FriendRequest.status,
                FriendRequest.updated_at,
                FriendRequest.created_at,
                User.first_name,
                User.last_name,
            )
            .join(User, FriendRequest.requester_id == User.id)
            .where(FriendRequest.recipient_id == id)
        )

        result = await paginate(
            self._session, query=query, params=params, subquery_count=True
        )
        return result

    async def get_all_sent_for(self, id: UUID, params: Params):
        query = (
            select(
                FriendRequest.id,
                FriendRequest.recipient_id,
                FriendRequest.status,
                FriendRequest.updated_at,
                FriendRequest.created_at,
                User.first_name,
                User.last_name,
            )
            .join(User, FriendRequest.recipient_id == User.id)
            .where(FriendRequest.requester_id == id)
        )

        result = await paginate(
            self._session, query=query, params=params, subquery_count=True
        )
        return result

    async def is_exists(self, *conditions):
        subquery = select(FriendRequest.id).where(*conditions).limit(1)
        stmt = select(exists(subquery))
        result = await self._session.execute(stmt)
        return result.scalar()

    async def is_valid_for_friend_request(self, id: UUID) -> bool:
        stmt = select(
            exists().where(
                User.id == id,
                User.is_active.is_(True),
                User.is_verified.is_(True),
            )
        ).select_from(User)
        result = await self._session.execute(stmt)
        return result.scalar()

    async def get(self, id: int):
        query = select(FriendRequest).where(FriendRequest.id == id)
        result = await self._session.execute(query)
        return result.scalar_one_or_none()

    async def delete(self, obj: FriendRequest) -> None:
        await self._session.delete(obj)

    async def update(
        self, obj: FriendRequest, dto: FriendRequestUpdateDTO
    ) -> FriendRequest:
        for key, value in asdict(dto).items():
            setattr(obj, key, value)

        await self._session.flush()

        return obj

    async def get_one_between(self, user1_id: UUID, user2_id: UUID) -> FriendRequest:
        query = select(FriendRequest).where(
            or_(
                FriendRequest.recipient_id == user1_id
                and FriendRequest.requester_id == user2_id,
                FriendRequest.recipient_id == user2_id
                and FriendRequest.requester_id == user1_id,
            )
        )

        result = await self._session.execute(query)
        return result.scalar_one_or_none()
