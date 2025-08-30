from sqlalchemy.ext.asyncio import AsyncSession

from core.quest.repositories import BaseSQLAlchemyRepository
from db.models.merch import Merch


class MerchRepository(BaseSQLAlchemyRepository[Merch]):
    def __init__(self, session: AsyncSession):
        super().__init__(session, Merch)
