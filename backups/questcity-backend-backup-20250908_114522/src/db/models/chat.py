import uuid
from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.db._types import _created_at, _updated_at, int32_pk
from src.db.base import Base

if TYPE_CHECKING:
    from db.models import User


class Message(Base):
    __tablename__ = "message"

    id: Mapped[int32_pk]
    text: Mapped[str]
    file_url: Mapped[str | None] = mapped_column(String(1024))
    is_read: Mapped[bool] = mapped_column(default=False)

    author_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("user.id"),
    )
    author: Mapped["User"] = relationship(backref="sended_messages")

    chat_id: Mapped[int] = mapped_column(ForeignKey("chat.id"))

    created_at: Mapped[_created_at]
    updated_at: Mapped[_updated_at]


class Chat(Base):
    __tablename__ = "chat"

    id: Mapped[int32_pk]

    messages: Mapped[list["Message"]] = relationship(
        backref="chat",
        lazy="selectin",
        order_by="desc(Message.created_at)",
    )
    participants: Mapped[list["User"]] = relationship(
        back_populates="chats",
        secondary="chat_participant",
        lazy="selectin",
    )

    created_at: Mapped[_created_at]
    updated_at: Mapped[_updated_at]


class ChatParticipant(Base):
    __tablename__ = "chat_participant"
    __table_args__ = (
        UniqueConstraint(
            "chat_id",
            "user_id",
            name="uq_only_two_users",
        ),
    )

    chat_id: Mapped[int] = mapped_column(
        ForeignKey("chat.id"),
        primary_key=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("user.id"),
        primary_key=True,
    )

    created_at: Mapped[_created_at]
