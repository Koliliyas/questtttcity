from dataclasses import asdict
from typing import TypeVar, Annotated
from uuid import UUID

from fastapi.encoders import jsonable_encoder
from fastapi_pagination import Params
from fastapi_pagination.ext.sqlalchemy import paginate
from sqlalchemy import exists, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload, selectinload

# Импортируем aioinject для аннотаций
import aioinject

from src.api.modules.quest.schemas.quest import ItemWithImageUpdateSchema
from src.core.quest.dto import (BaseReviewDTO, BaseReviewResponseDTO,
                            PointCreateDTO, PointUpdateDTO)
from src.core.repositories import BaseSQLAlchemyRepository
from src.db.base import Base
from src.db.models import (Activity, Category, Place, PlaceSettings, Point, Quest,
                       Review, Tool, Vehicle)
from src.db.models.quest.quest import ReviewResponse
from src.db.models.user import User

ModelType = TypeVar("ModelType", bound=Base)


class QuestRepository(BaseSQLAlchemyRepository[Quest]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]) -> None:
        super().__init__(session, Quest)

    async def get_current_quest(self, id_: int) -> Quest | None:
        return await self._session.scalar(
            select(self._model)
            .where(self._model.id == id_)
            .options(
                selectinload(self._model.points).options(selectinload(Point.places))
            )
        )

    async def get_quest(self, id_: int) -> Quest | None:
        return await self._session.scalar(
            select(self._model)
            .options(
                selectinload(self._model.category),  # Добавляем загрузку категории
                selectinload(self._model.merch),
                selectinload(self._model.reviews).options(selectinload(Review.user)),
                selectinload(self._model.points).options(selectinload(Point.places)),
            )
            .where(self._model.id == id_)
        )

    async def get_quest_before_update(self, oid: int) -> Quest:
        return await self._session.scalar(
            select(self._model)
            .where(self._model.id == oid)
            .options(
                selectinload(self._model.category),  # Добавляем загрузку категории
                selectinload(self._model.merch),
                selectinload(self._model.points).selectinload(Point.places)
            )
        )


class PointRepository(BaseSQLAlchemyRepository[Point]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]):
        super().__init__(session, Point)

    async def add_point(self, dto: PointCreateDTO):
        data = asdict(dto)
        data.pop("places")
        self._session.add(point := self._model(**data))
        await self._session.flush()
        return point

    async def update_point(self, dto: PointUpdateDTO, obj: Point):
        obj_data = jsonable_encoder(obj)

        update_data = asdict(dto)
        update_data.pop("places")

        for field in obj_data:
            if field in update_data:
                setattr(obj, field, update_data[field])

        self._session.add(obj)
        await self._session.flush()
        return obj

    async def check_qty(self, quest_oid: int, target_qty: int = 2) -> bool:
        qty = await self._session.scalar(
            select(func.count(self._model.id)).where(self._model.quest_id == quest_oid)
        )
        return qty > target_qty


class PlacePreferenceRepository(BaseSQLAlchemyRepository[PlaceSettings]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]):
        super().__init__(session, PlaceSettings)

    async def check_qty(self, point_oid: int, target_qty: int = 1) -> bool:
        qty = await self._session.scalar(
            select(func.count(self._model.id)).where(self._model.point_id == point_oid)
        )
        return qty > target_qty


class PlaceRepository(BaseSQLAlchemyRepository[Place]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]):
        super().__init__(session, Place)


class CategoryRepository(BaseSQLAlchemyRepository[Category]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]):
        super().__init__(session, Category)

    async def update_category(
        self,
        obj: Category,
        data: ItemWithImageUpdateSchema,
    ) -> Category:
        update_data = data.model_dump(exclude_none=True)

        for field in jsonable_encoder(obj):
            if field in update_data:
                setattr(obj, field, update_data[field])

        self._session.add(obj)
        await self._session.flush()
        await self._session.refresh(obj)
        return obj


class VehicleRepository(BaseSQLAlchemyRepository[Vehicle]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]):
        super().__init__(session, Vehicle)


class ToolRepository(BaseSQLAlchemyRepository[Tool]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]):
        super().__init__(session, Tool)


class TypeRepository(BaseSQLAlchemyRepository[Activity]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]):
        super().__init__(session, Activity)


class ReviewRepository(BaseSQLAlchemyRepository[Review]):
    def __init__(self, session: Annotated[AsyncSession, aioinject.Inject]):
        super().__init__(session, Review)

    async def create(
        self,
        dto: BaseReviewDTO,
    ):
        data = asdict(dto)
        result = Review(**data)
        self._session.add(result)
        await self._session.flush()
        return result

    async def create_response(self, dto: BaseReviewResponseDTO):
        data = asdict(dto)
        result = ReviewResponse(**data)
        self._session.add(result)
        await self._session.flush()
        return result

    async def is_exists(self, *conditions):
        subquery = select(Review.id).where(*conditions).limit(1)
        stmt = select(exists(subquery))
        result = await self._session.execute(stmt)
        return result.scalar()

    async def is_has_response(self, review_id: int, user_id: UUID):
        subquery = select(ReviewResponse.id).where(
            ReviewResponse.review_id == review_id, ReviewResponse.user_id == user_id
        )
        stmt = select(exists(subquery))
        result = await self._session.execute(stmt)
        return result.scalar()

    async def get_all(self, quest_id: int, params: Params):
        query = (
            select(Review)
            .where(Review.quest_id == quest_id)
            .options(
                joinedload(Review.user).joinedload(User.profile),
                joinedload(Review.manager_response)
                .joinedload(ReviewResponse.user)
                .joinedload(User.profile),
            )
        )
        result = await paginate(
            self._session, query=query, params=params, subquery_count=True
        )
        print(result)
        return result
