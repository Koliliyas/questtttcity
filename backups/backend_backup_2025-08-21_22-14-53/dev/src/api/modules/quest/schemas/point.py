import base64
from typing import Optional

from pydantic import Field, field_validator, model_validator

from api.modules.quest.schemas.mixins import (DescriptionNotEmptyMixin,
                                              IdIsRequiredMixin)
from core.quest.enums import TakePhoto
from core.schemas import BaseSchema


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
    description: str
    order: int = 1
    type: PointType
    tool_id: Optional[int]
    places: list[PlaceSettings]
    files: Optional[FileSettings] = None

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
        files = data.get("files")
        places = data["places"]

        if files is not None:
            if len(places) < 2 and files.get("is_divide"):
                raise ValueError(
                    "You must be specify places more then 1 when you divide artifact."
                )

            if len(places) > 1 and not files.get("is_divide"):
                raise ValueError(
                    "You must be specify 'is_divide' is true when you divide artifact."
                )

        if files is None and len(places) > 1:
            raise ValueError("You must specify artifact file to divide him.")

        return data


# Point read schemas:
class FileReadSettings(BaseSchema):
    file: str
    is_divide: bool = False


class PointReadForCurrentQuestSchema(BaseSchema):
    name_of_location: str
    description: str
    order: int
    type: PointType
    tool_id: Optional[int]
    places: list[PlaceSettings]
    files: Optional[FileReadSettings]


class PlaceModel(BaseSchema):
    latitude: float
    longitude: float


class PointReadSchema(BaseSchema):
    name_of_location: str = Field(..., alias="name")
    order: int
    description: str
    places: list[PlaceModel]


# Point update schemas:
class PlacesUpdateSchema(IdIsRequiredMixin, PlaceSettings):
    id: Optional[int] = None
    is_delete: bool = False


class PointUpdateSchema(IdIsRequiredMixin, PointCreateSchema):
    id: Optional[int] = None
    is_delete: bool = False
    places: list[PlacesUpdateSchema]
