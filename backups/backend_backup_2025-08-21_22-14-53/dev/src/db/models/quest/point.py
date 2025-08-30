from typing import TYPE_CHECKING

from sqlalchemy import Enum, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from core.quest.enums import TakePhoto
from db._types import int32_pk
from db.base import Base

if TYPE_CHECKING:
    from db.models import Quest


class Activity(Base):
    __tablename__ = "activity"

    id: Mapped[int32_pk]
    name: Mapped[str] = mapped_column(String(32), unique=True)

    points: Mapped[list["Point"]] = relationship(back_populates="type")


class Tool(Base):
    __tablename__ = "tool"

    id: Mapped[int32_pk]
    name: Mapped[str] = mapped_column(String(32), unique=True)
    image: Mapped[str] = mapped_column(String(1024))

    points: Mapped[list["Point"]] = relationship(back_populates="tool")


class PlaceSettings(Base):
    __tablename__ = "place_settings"

    id: Mapped[int32_pk]
    longitude: Mapped[float]
    latitude: Mapped[float]
    detections_radius: Mapped[float]
    height: Mapped[float] = mapped_column(default=1.8)
    random_occurrence: Mapped[float | None]
    interaction_inaccuracy: Mapped[float]
    part: Mapped[int | None]

    point_id: Mapped[int] = mapped_column(ForeignKey("point.id"))
    point: Mapped["Point"] = relationship(back_populates="places")


class Point(Base):
    __tablename__ = "point"

    id: Mapped[int32_pk]

    # Base point's settings on Quest:
    name_of_location: Mapped[str] = mapped_column(String(32))
    order: Mapped[int]
    description: Mapped[str]

    # Type choice:
    type_id: Mapped[int] = mapped_column(ForeignKey("activity.id"))
    type: Mapped["Activity"] = relationship(back_populates="points")
    type_photo: Mapped[TakePhoto | None] = mapped_column(Enum(TakePhoto))
    type_code: Mapped[str | None]
    type_word: Mapped[str | None] = mapped_column(String(32))

    # Tool choice:
    tool_id: Mapped[int | None] = mapped_column(ForeignKey("tool.id"))
    tool: Mapped["Tool"] = relationship(back_populates="points")

    # Place settings:
    places: Mapped[list["PlaceSettings"]] = relationship(
        back_populates="point",
        cascade="delete",
    )

    # File choice:
    file: Mapped[str | None] = mapped_column(String(1024))
    is_divide: Mapped[bool | None]

    # Relationships with the quest:
    quest_id: Mapped[int] = mapped_column(ForeignKey("quest.id"))
    quest: Mapped["Quest"] = relationship(back_populates="points")
