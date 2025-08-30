from datetime import datetime

from src.core.schemas import BaseSchema


class FavoriteCreateSchema(BaseSchema):
    quest_id: int


class FavoriteReadSchema(BaseSchema):
    id: int
    quest_id: int
    created_at: datetime
    updated_at: datetime


class FavoritesReadSchema(BaseSchema):
    items: list[FavoriteReadSchema]
