from typing import TYPE_CHECKING

from sqlalchemy import Computed, ForeignKey, Index, Integer, String, text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.db._types import _created_at, _updated_at, int32_pk, uuid_pk
from src.db.base import Base

if TYPE_CHECKING:
    from db.models import Chat, Review
    from db.models.quest.quest import ReviewResponse
    from db.models.favorite import Favorite


class Profile(Base):
    __tablename__ = "profile"

    id: Mapped[int32_pk]
    avatar_url: Mapped[str] = mapped_column(String(1024), nullable=True)
    user: Mapped["User"] = relationship(
        "User",
        back_populates="profile",
        uselist=False,
    )
    instagram_username: Mapped[str] = mapped_column(
        String(1024), nullable=False, default=""
    )
    credits: Mapped[int] = mapped_column(Integer, default=0, nullable=False)


class User(Base):
    __tablename__ = "user"

    id: Mapped[uuid_pk]
    username: Mapped[str] = mapped_column(
        String(15), nullable=False, unique=True, index=True
    )
    first_name: Mapped[str] = mapped_column(String(128), nullable=False)
    last_name: Mapped[str] = mapped_column(String(128), nullable=False)
    full_name: Mapped[str] = mapped_column(
        String(257), Computed("first_name || ' ' || last_name", persisted=True)
    )
    password: Mapped[str] = mapped_column(String(1024), nullable=False)
    # TODO: add email validation in database
    email: Mapped[str] = mapped_column(
        String(30), unique=True, index=True, nullable=False
    )

    profile_id: Mapped[int] = mapped_column(
        ForeignKey("profile.id", ondelete="CASCADE"), nullable=False, unique=True
    )
    profile: Mapped[Profile] = relationship(
        "Profile", back_populates="user", uselist=False
    )

    review_responses: Mapped[list["ReviewResponse"]] = relationship(
        back_populates="user", lazy="joined", cascade="all, delete-orphan"
    )

    reviews: Mapped[list["Review"]] = relationship(
        back_populates="user",  # Должно совпадать с именем в Review
        lazy="selectin",
    )
    favorites: Mapped[list["Favorite"]] = relationship(back_populates="user")

    role: Mapped[int] = mapped_column(default=0, nullable=False)
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)
    is_verified: Mapped[bool] = mapped_column(default=False, nullable=False)
    can_edit_quests: Mapped[bool] = mapped_column(default=False, nullable=False, server_default="false")
    can_lock_users: Mapped[bool] = mapped_column(default=False, nullable=False, server_default="false")
    created_at: Mapped[_created_at]
    updated_at: Mapped[_updated_at]

    # Chat
    chats: Mapped[list["Chat"]] = relationship(
        back_populates="participants",
        secondary="chat_participant",
    )

    __table_args__ = (
        Index(
            "user_username_first_name_last_name_trgm_idx",
            text("username gin_trgm_ops"),
            text("full_name gin_trgm_ops"),
            postgresql_using="gin",
        ),
        # Index(
        #     'first_name_last_name_combined_trgm_idx',
        #     func.concat('first_name', ' ', 'last_name'),
        #     postgresql_using='gin',
        #     postgresql_ops={'concat': 'gin_trgm_ops'}
        # ),
    )
