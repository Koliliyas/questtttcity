import statistics
from typing import TYPE_CHECKING, Any, Optional

from sqlalchemy import (CheckConstraint, Enum, ForeignKey, Label, String,
                        UniqueConstraint, func, select)
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import Mapped, mapped_column, relationship

from core.quest.enums import GroupType, Level, Milage, Timeframe
from db._types import _created_at, _updated_at, int32_pk
from db.base import Base

if TYPE_CHECKING:
    from db.models import Favorite, Merch, Point, User


class Place(Base):
    __tablename__ = "place"

    id: Mapped[int32_pk]
    name: Mapped[str] = mapped_column(String(16), unique=True)

    quests: Mapped[list["Quest"]] = relationship(
        back_populates="place",
        lazy="selectin",
    )


class Vehicle(Base):
    __tablename__ = "vehicle"

    id: Mapped[int32_pk]
    name: Mapped[str] = mapped_column(String(16), unique=True)

    quests: Mapped[list["Quest"]] = relationship(
        back_populates="vehicle",
        lazy="selectin",
    )


class Category(Base):
    __tablename__ = "category"

    id: Mapped[int32_pk]
    name: Mapped[str] = mapped_column(String(16), unique=True)
    image: Mapped[str] = mapped_column(String(1024))

    created_at: Mapped[_created_at]
    updated_at: Mapped[_updated_at]

    quests: Mapped[list["Quest"]] = relationship(
        back_populates="category",
        lazy="selectin",
    )


class ReviewResponse(Base):
    __tablename__ = "review_response"

    id: Mapped[int] = mapped_column(primary_key=True)
    text: Mapped[str] = mapped_column(nullable=False)

    created_at: Mapped[_created_at]
    updated_at: Mapped[_updated_at]

    review_id: Mapped[int] = mapped_column(
        ForeignKey("review.id", ondelete="CASCADE"), unique=True
    )
    review: Mapped["Review"] = relationship(
        back_populates="manager_response", uselist=False, lazy="joined"
    )

    user_id: Mapped[int] = mapped_column(ForeignKey("user.id"))
    user: Mapped["User"] = relationship(
        back_populates="review_responses", lazy="joined"
    )

    __table_args__ = (UniqueConstraint("review_id", name="uq_response_per_review"),)


class Review(Base):
    __tablename__ = "review"

    id: Mapped[int32_pk]
    text: Mapped[str]
    rating: Mapped[int] = mapped_column()

    created_at: Mapped[_created_at]
    updated_at: Mapped[_updated_at]

    __table_args__ = (
        CheckConstraint("rating >= 1 AND rating <= 5", name="rating_check"),
    )

    # Ralations:
    user_id: Mapped[int] = mapped_column(ForeignKey("user.id"))
    user: Mapped["User"] = relationship(back_populates="reviews", lazy="joined")
    quest_id: Mapped[int] = mapped_column(ForeignKey("quest.id"))
    quest: Mapped["Quest"] = relationship(back_populates="reviews", lazy="joined")

    __table_args__ = (
        UniqueConstraint("user_id", "quest_id", name="uq_user_quest_review"),
    )

    manager_response: Mapped[Optional["ReviewResponse"]] = relationship(
        back_populates="review", uselist=False, cascade="all, delete-orphan"
    )


class Quest(Base):
    __tablename__ = "quest"

    # General:
    id: Mapped[int32_pk]
    name: Mapped[str] = mapped_column(String(32), unique=True)
    description: Mapped[str]

    # Files:
    image: Mapped[str] = mapped_column(String(1024))
    mentor_preference: Mapped[str] = mapped_column(String(1024))

    # Merch:
    merch: Mapped[list["Merch"]] = relationship(
        back_populates="quest",
        uselist=True,
        cascade="all, delete-orphan",
    )

    # Credit:
    auto_accrual: Mapped[bool]
    cost: Mapped[int] = mapped_column(default=0)
    reward: Mapped[int]

    # Main preference:
    category_id: Mapped[int] = mapped_column(ForeignKey("category.id"))
    category: Mapped["Category"] = relationship(back_populates="quests")
    group: Mapped[GroupType] = mapped_column(Enum(GroupType))
    vehicle_id: Mapped[int] = mapped_column(ForeignKey("vehicle.id"))
    vehicle: Mapped["Vehicle"] = relationship(back_populates="quests")

    is_subscription: Mapped[bool] = mapped_column(default=False)
    pay_extra: Mapped[int] = mapped_column(default=0)

    timeframe: Mapped[Timeframe | None] = mapped_column(Enum(Timeframe))
    level: Mapped[Level] = mapped_column(Enum(Level))
    milage: Mapped[Milage] = mapped_column(Enum(Milage))
    place_id: Mapped[int] = mapped_column(ForeignKey("place.id"))
    place: Mapped["Place"] = relationship(back_populates="quests")

    favorited_by: Mapped[list["Favorite"]] = relationship(back_populates="quest")

    # Points:
    points: Mapped[list["Point"]] = relationship(
        back_populates="quest",
        uselist=True,
        lazy="selectin",
        cascade="delete",
    )

    # Reviews:
    reviews: Mapped[list["Review"]] = relationship(
        back_populates="quest",
        uselist=True,
        lazy="selectin",
        cascade="delete",
    )

    created_at: Mapped[_created_at]
    updated_at: Mapped[_updated_at]

    @hybrid_property
    def rating(self) -> float:
        """Вычисление среднего рейтинга квеста."""
        if reviews := self.reviews:
            return statistics.mean((review.rating for review in reviews))
        return 0.0

    @rating.inplace.expression
    @classmethod
    def _rating_expression(cls) -> Label[Any]:
        """SQL выражение для вычисления среднего рейтинга квеста."""
        return (
            select(func.avg(Review.rating))
            .where(Review.quest_id == cls.id)
            .label("average_rating")
        )
