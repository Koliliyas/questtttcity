import enum

from sqlalchemy import Enum, String
from sqlalchemy.orm import Mapped, mapped_column

from src.db._types import _created_at, _updated_at, int32_pk
from src.db.base import Base


class UnlockRequestStatus(str, enum.Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class UnlockRequest(Base):
    __tablename__ = "unlock_request"

    id: Mapped[int32_pk]
    email: Mapped[str] = mapped_column(nullable=False)
    reason: Mapped[str] = mapped_column(String(128))
    status: Mapped[str] = mapped_column(
        Enum(UnlockRequestStatus), name="unlock_request_status_enum", default="pending"
    )
    message: Mapped[str] = mapped_column(String(1024))
    updated_at: Mapped[_updated_at]
    created_at: Mapped[_created_at]
