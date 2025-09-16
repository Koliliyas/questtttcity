from uuid import UUID

from sqlalchemy import JSON, ForeignKey, Integer, PrimaryKeyConstraint, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from core.authentication.utils import (get_random_refresh_token,
                                       get_random_token,
                                       get_random_verification_code)
from db._types import _created_at
from db.base import Base
from db.models.user import User


class RefreshToken(Base):
    __tablename__ = "refresh_token"

    id: Mapped[str] = mapped_column(
        String(45), primary_key=True, default=get_random_refresh_token
    )
    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("user.id", ondelete="CASCADE"), nullable=False
    )
    user: Mapped[User] = relationship()
    created_at: Mapped[_created_at]


class EmailVerificationCode(Base):
    __tablename__ = "email_verification_code"
    code: Mapped[int] = mapped_column(
        Integer, nullable=False, default=get_random_verification_code
    )
    email: Mapped[str] = mapped_column(String(30), nullable=False)
    created_at: Mapped[_created_at]
    optional_data = mapped_column(JSON)

    __table_args__ = (PrimaryKeyConstraint("code", "email"),)


class ResetPasswordToken(Base):
    __tablename__ = "reset_password_token"

    id: Mapped[str] = mapped_column(
        String(45), primary_key=True, default=get_random_token
    )
    email: Mapped[str] = mapped_column(String(30), nullable=False)
    created_at: Mapped[_created_at]
