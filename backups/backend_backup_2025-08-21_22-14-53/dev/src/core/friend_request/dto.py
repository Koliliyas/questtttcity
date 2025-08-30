from dataclasses import dataclass
from uuid import UUID


@dataclass
class FriendRequestCreateDTO:
    requester_id: UUID
    recipient_id: UUID


@dataclass
class FriendRequestUpdateDTO:
    status: str
