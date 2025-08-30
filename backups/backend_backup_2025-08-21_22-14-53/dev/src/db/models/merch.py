from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from db._types import int32_pk
from db.base import Base

if TYPE_CHECKING:
    from db.models import Quest


class Merch(Base):
    __tablename__ = "merch"

    id: Mapped[int32_pk]
    description: Mapped[str]
    price: Mapped[float]
    image: Mapped[str] = mapped_column(String(1024))

    quest_id: Mapped[int] = mapped_column(ForeignKey("quest.id"))
    quest: Mapped["Quest"] = relationship(back_populates="merch")
