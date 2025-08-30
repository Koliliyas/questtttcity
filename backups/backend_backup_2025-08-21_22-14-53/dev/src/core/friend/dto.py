from dataclasses import dataclass
from uuid import UUID


@dataclass
class FriendCreateDTO:
    me_id: UUID
    friend_id: UUID
