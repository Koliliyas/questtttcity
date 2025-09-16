import base64
from typing import Optional

from pydantic import Field, field_validator, model_validator

from src.api.modules.quest.schemas.mixins import (DescriptionNotEmptyMixin,
                                              IdIsRequiredMixin)
from src.core.quest.enums import TakePhoto
from src.core.schemas import BaseSchema


class QuestItemRead(BaseSchema):
    id: int
    name: str
    image: Optional[str]


class Tool(QuestItemRead):
    image: str


class PointType(BaseSchema):
    type_id: int
    type_photo: Optional[TakePhoto] = None
    type_code: Optional[str] = None
    type_word: Optional[str] = Field(None, min_length=1, max_length=32)


class PlaceSettings(BaseSchema):
    part: Optional[int]
    longitude: float
    latitude: float
    detections_radius: float = Field(..., ge=5, le=10)
    height: float = 1.8
    random_occurrence: Optional[float] = Field(None, ge=5, le=10)
    interaction_inaccuracy: float = Field(..., ge=5, le=10)


class FileSettings(BaseSchema):
    file: str
    is_divide: bool = False

    @field_validator("file")
    def validate_file(cls, value: str) -> str:
        try:
            if value.startswith("data:"):
                _, value = value.split(",", 1)

            base64.b64decode(value, validate=True)

        except (ValueError, TypeError) as exception:
            raise ValueError("Invalid base64 string.") from exception


class PointCreateSchema(DescriptionNotEmptyMixin, BaseSchema):
    name_of_location: str = Field(..., max_length=32, min_length=1)
    description: str = Field(..., max_length=500)  # Добавляем поле description
    order: int = 1
    type_id: int  # Изменено с type: PointType на type_id: int
    tool_id: Optional[int]
    places: list[PlaceSettings]
    file: Optional[str] = None  # Изменено с files: Optional[FileSettings] на file: Optional[str]
    # type_photo: Optional[str] = None  # ← ВРЕМЕННО УБРАНО
    # type_code: Optional[int] = None  # ← ВРЕМЕННО УБРАНО
    # type_word: Optional[str] = None  # ← ВРЕМЕННО УБРАНО
    is_divide: bool = False  # Добавляем поле is_divide

    @field_validator("places")
    def validate_places(cls, value: list[PlaceSettings]) -> list[PlaceSettings]:
        if len(value) > 1:
            for place in value:
                if place.part is None:
                    raise ValueError("You must specify part for each place.")

                if place.part > len(value):
                    raise ValueError("Part must be less than the number of places.")

        return value

    @model_validator(mode="before")
    @classmethod
    def validate_places_with_files(cls, data: dict):
        file = data.get("file")
        places = data["places"]

        if file is not None:
            if len(places) < 2:
                raise ValueError(
                    "You must be specify places more then 1 when you divide artifact."
                )

        if file is None and len(places) > 1:
            raise ValueError("You must specify artifact file to divide him.")

        return data


# Point read schemas:
class FileReadSettings(BaseSchema):
    file: str
    is_divide: bool = False


class PointReadForCurrentQuestSchema(BaseSchema):
    name_of_location: str
    order: int
    type: PointType
    tool_id: Optional[int]
    places: list[PlaceSettings]
    files: Optional[FileReadSettings]


class PlaceModel(BaseSchema):
    latitude: float
    longitude: float


class PointReadSchema(BaseSchema):
    id: int  # Добавляем ID точки для чтения
    name_of_location: str = Field(..., alias="name")
    order: int
    description: str = ""  # Добавляем description
    type_id: Optional[int] = None  # Добавляем type_id для редактирования
    tool_id: Optional[int] = None  # Добавляем tool_id для редактирования
    places: list[PlaceModel]


# Point update schemas:
class PlacesUpdateSchema(IdIsRequiredMixin, PlaceSettings):
    id: Optional[int] = None
    is_delete: bool = False


class PointUpdateSchema(IdIsRequiredMixin, PointCreateSchema):
    id: Optional[int] = None
    is_delete: bool = False
    places: list[PlacesUpdateSchema]
