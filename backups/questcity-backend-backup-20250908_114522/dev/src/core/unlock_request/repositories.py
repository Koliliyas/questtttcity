from fastapi_pagination import Params
from fastapi_pagination.ext.sqlalchemy import paginate
from sqlalchemy import exists, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.unlock_request.filters import UnlockRequestFilter
from core.unlock_request.dto import (UnlockRequestCreateDTO,
                                     UnlockRequestUpdateDTO)
from db.models.unlock_request import UnlockRequest
from db.models.user import User


class UnlockRequestRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def create(self, unlock_request_dto: UnlockRequestCreateDTO):
        obj = UnlockRequest(
            email=unlock_request_dto.email,
            reason=unlock_request_dto.reason,
            message=unlock_request_dto.message,
        )
        self._session.add(obj)
        await self._session.flush()
        return obj

    async def has_pending_unlock_request(self, email: str) -> bool:
        stmt = select(
            exists().where(
                UnlockRequest.email == email, UnlockRequest.status == "pending"
            )
        )
        return await self._session.scalar(stmt)

    async def has_active_status(self, email: str) -> bool:
        stmt = select(exists().where(User.email == email, User.is_active))
        return await self._session.scalar(stmt)

    async def get_all(self, filter: UnlockRequestFilter, pagination_params: Params):
        query = select(UnlockRequest)
        filter_query = filter.filter(query=query)
        result = await paginate(
            self._session,
            query=filter_query,
            params=pagination_params,
            subquery_count=True,
        )
        return result

    async def get_one(self, id_: int) -> UnlockRequest:
        query = select(UnlockRequest).where(UnlockRequest.id == id_)
        result = await self._session.execute(query)
        return result.scalar_one_or_none()

    async def update(self, id_: int, dto: UnlockRequestUpdateDTO):
        query = (
            update(UnlockRequest)
            .where(UnlockRequest.id == id_)
            .values(dto.get_non_none_fields())
            .execution_options(synchronize_session="fetch")
        )
        result = await self._session.execute(query)
        return result.rowcount
