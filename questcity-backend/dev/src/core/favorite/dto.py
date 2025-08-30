from dataclasses import dataclass
from uuid import UUID


@dataclass
class BaseFavoriteDTO:
    quest_id: int
    user_id: UUID
