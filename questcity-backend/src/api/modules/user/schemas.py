from datetime import datetime
from string import punctuation
from typing import Optional

from pydantic import UUID4, field_validator

from src.core.schemas import (BaseSchema, CustomEmailStr, FirstNameStr,
                          LastNameStr, UsernameStr)


class ProfileReadSchema(BaseSchema):
    id: int
    avatar_url: Optional[str]
    credits: int
    instagram_username: str


class UserReadSchema(BaseSchema):
    id: UUID4
    username: str
    email: str
    first_name: str
    last_name: str
    profile: ProfileReadSchema
    role: int
    is_active: bool
    is_verified: bool
    can_edit_quests: bool
    can_lock_users: bool
    created_at: datetime
    updated_at: datetime


class PasswordSchema(BaseSchema):
    password1: str
    password2: str

    @field_validator("password2")
    def validate_password(cls, v, values):
        if not values.data["password1"] == v:
            raise ValueError("Passwords do not match")

        if len(v) < 8:
            raise ValueError("Password length should be at least 8")

        if not any(char.islower() for char in v):
            raise ValueError("Password should have at least one lowercase letter")

        if not any(char.isdigit() for char in v):
            raise ValueError("Password should have at least one numeral")

        if not any(char.isupper() for char in v):
            raise ValueError("Password should have at least one uppercase letter")

        if not any(char in punctuation for char in v):
            raise ValueError("Password should have at least one of the special symbols")

        return v


class UserCreateSchema(PasswordSchema, BaseSchema):
    username: UsernameStr
    email: CustomEmailStr
    first_name: FirstNameStr
    last_name: LastNameStr


class UserUpdateSchema(BaseSchema):
    username: Optional[UsernameStr] = None
    email: Optional[CustomEmailStr] = None
    first_name: Optional[FirstNameStr] = None
    last_name: Optional[LastNameStr] = None


class UserCreateAdminSchema(PasswordSchema, BaseSchema):
    username: UsernameStr
    email: CustomEmailStr
    first_name: FirstNameStr
    last_name: LastNameStr
    role: int
    is_active: bool
    is_verified: bool
    can_edit_quests: bool
    can_lock_users: bool


class UserUpdateAdminSchema(BaseSchema):
    username: Optional[UsernameStr] = None
    first_name: Optional[FirstNameStr] = None
    last_name: Optional[LastNameStr] = None
    email: Optional[CustomEmailStr] = None
    password: Optional[str] = None
    role: Optional[int] = None
    is_active: Optional[bool] = None
    is_verified: Optional[bool] = None
    can_edit_quests: Optional[bool] = None
    can_lock_users: Optional[bool] = None

    @field_validator("password")
    def validate_password(cls, v, values):
        if len(v) < 8:
            raise ValueError("Password length should be at least 8")

        if not any(char.islower() for char in v):
            raise ValueError("Password should have at least one lowercase letter")

        if not any(char.isdigit() for char in v):
            raise ValueError("Password should have at least one numeral")

        if not any(char.isupper() for char in v):
            raise ValueError("Password should have at least one uppercase letter")

        if not any(char in punctuation for char in v):
            raise ValueError("Password should have at least one of the special symbols")

        return v


class EmailChangeSchema(BaseSchema):
    email: CustomEmailStr
    code: int


class ChangePasswordSchema(PasswordSchema):
    old_password: str
