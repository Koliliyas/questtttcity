from dataclasses import dataclass

from src.core.dto import BaseUpdateDTO


@dataclass
class UserCreateDTO:
    username: str
    first_name: str
    last_name: str
    password: str
    email: str
    profile_id: int | None = None


@dataclass
class UserCreateAdminDTO:
    username: str
    first_name: str
    last_name: str
    password: str
    email: str
    role: int
    is_active: bool
    is_verified: bool
    profile_id: int | None = None
    can_edit_quests: bool | None = None
    can_lock_users: bool | None = None


@dataclass
class UserUpdateDTO(BaseUpdateDTO):
    username: str | None = None
    first_name: str | None = None
    last_name: str | None = None


@dataclass
class UserUpdateAdminDTO(BaseUpdateDTO):
    username: str | None = None
    first_name: str | None = None
    last_name: str | None = None
    email: str | None = None
    password: str | None = None
    role: int | None = None
    is_active: bool | None = None
    is_verified: bool | None = None
    can_edit_quests: bool | None = None
    can_lock_users: bool | None = None


@dataclass
class ProfileCreateDTO:
    avatar_url: str
