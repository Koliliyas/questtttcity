import base64
from typing import Optional

from pydantic import BaseModel, Field, field_validator

from api.modules.quest.schemas.mixins import (DescriptionNotEmptyMixin,
                                              IdIsRequiredMixin,
                                              ImageValidateMixin)
from core.quest.enums import GroupType, Level, Milage, Timeframe
from core.schemas import BaseSchema
from src.api.modules.quest.schemas.point import (
    PointCreateSchema, PointReadForCurrentQuestSchema, PointReadSchema,
    PointUpdateSchema)


# Item create schemas:
class ItemRequestSchema(BaseSchema):
    name: str = Field(..., min_length=2, max_length=16)

    @field_validator("name")
    def validate_name(cls, value: str) -> str:
        if not value:
            raise ValueError("Name can't be empty.")

        if value.isdigit():
            raise ValueError("Name field must contains letters.")

        return value


class ItemWithImageRequestSchema(ImageValidateMixin, ItemRequestSchema):
    image: str


# Item update schemas:
class ItemUpdateSchema(ItemRequestSchema):
    name: Optional[str] = Field(None, min_length=2, max_length=16)

    @field_validator("name")
    def validate_name(cls, value: str) -> str:
        if value is not None:
            return super().validate_name(value)

        return value


class ItemWithImageUpdateSchema(ImageValidateMixin, ItemUpdateSchema):
    image: Optional[str] = None


# Item read schemas:
class ItemReadSchema(ItemRequestSchema):
    id: int


class ItemWithImageRead(ItemReadSchema):
    image: str


class MerchRequestSchema(DescriptionNotEmptyMixin, ImageValidateMixin, BaseSchema):
    description: str
    price: int
    image: str


class Credits(BaseModel):
    auto: bool
    cost: int = 0
    reward: int = Field(..., ge=0)


class PriceSettings(BaseModel):
    is_subscription: bool = False
    pay_extra: int = 0


class MainPreferences(BaseModel):
    category_id: int
    group: GroupType
    vehicle_id: int
    price: PriceSettings
    timeframe: Optional[Timeframe]
    level: Level
    milage: Milage
    place_id: int


class QuestCreteSchema(DescriptionNotEmptyMixin, ImageValidateMixin, BaseSchema):
    name: str = Field(..., min_length=1, max_length=32)
    description: str
    image: str

    merch: list[MerchRequestSchema] = Field(default_factory=list)
    credits: Credits
    main_preferences: MainPreferences
    mentor_preferences: str

    points: list[PointCreateSchema]

    @field_validator("mentor_preferences")
    def validate_mentor_preferences(cls, value: str) -> str:
        # TODO: Валидировать эксель документ
        try:
            if value.startswith("data:"):
                _, value = value.split(",", 1)

            base64.b64decode(value, validate=True)

        except (ValueError, TypeError) as exception:
            raise ValueError("Invalid base64 string.") from exception

        return value


class QuestAsItem(BaseSchema):
    id: int
    name: str
    image: str
    rating: float

    main_preferences: MainPreferences


class MerchReadSchema(BaseSchema):
    id: int
    description: str
    price: int
    image: str


class QuestReadSchema(BaseSchema):
    name: str
    image: str
    merch: list[MerchReadSchema]
    credits: Credits
    main_preferences: MainPreferences
    points: list[PointReadSchema]


class CurrentQuestSchema(BaseSchema):
    mentor_preferences: str
    points: list[PointReadForCurrentQuestSchema]


# Update quest schemas:
class UpdateMerhSchema(IdIsRequiredMixin, MerchRequestSchema):
    id: Optional[int] = None
    is_delete: bool = False
    image: Optional[str] = None


class QuestUpdateRequestSchema(QuestCreteSchema):
    merch: list[UpdateMerhSchema] = Field(default_factory=list)
    points: list[PointUpdateSchema]
    image: Optional[str] = None
    mentor_preferences: Optional[str] = None
