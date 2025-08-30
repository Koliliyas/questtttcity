import enum
import uuid

from sqlalchemy import Enum, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from src.db._types import _created_at, _updated_at, int32_pk
from src.db.base import Base


class FriendRequestStatus(enum.Enum):
    sended = "sended"
    rejected = "rejected"
    accepted = "accepted"


class FriendRequest(Base):
    __tablename__ = "friend_request"

    id: Mapped[int32_pk]
    requester_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("user.id")
    )
    recipient_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("user.id")
    )
    status: Mapped[str] = mapped_column(
        Enum(FriendRequestStatus), name="friend_request_status_enum", default="sended"
    )

    updated_at: Mapped[_updated_at]
    created_at: Mapped[_created_at]

    __table_args__ = (
        UniqueConstraint("requester_id", "recipient_id", name="unique_request_idx"),
    )
