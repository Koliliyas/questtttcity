from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from db._types import _created_at, _updated_at
from db.base import Base

if TYPE_CHECKING:
    from db.models.quest.quest import Quest
    from db.models.user import User


class Favorite(Base):
    __tablename__ = "favorite"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("user.id", ondelete="CASCADE"))
    quest_id: Mapped[int] = mapped_column(ForeignKey("quest.id", ondelete="CASCADE"))

    created_at: Mapped[_created_at]
    updated_at: Mapped[_updated_at]

    user: Mapped["User"] = relationship(back_populates="favorites")
    quest: Mapped["Quest"] = relationship(back_populates="favorited_by")

    __table_args__ = (UniqueConstraint("user_id", "quest_id", name="unique_favorite"),)
