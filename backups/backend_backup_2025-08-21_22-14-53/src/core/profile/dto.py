from dataclasses import dataclass

from src.core.dto import BaseUpdateDTO


@dataclass
class ProfileUpdateDTO(BaseUpdateDTO):
    avatar_url: str | None
    instagram_username: str | None
    credits: str | None
