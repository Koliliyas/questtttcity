from datetime import datetime
from typing import Literal, Optional
from uuid import UUID

from src.core.schemas import BaseSchema


class FriendRequestSentReadSchema(BaseSchema):
    id: int
    first_name: str
    last_name: str
    recipient_id: UUID
    status: str
    created_at: datetime
    updated_at: datetime


class FriendRequestReceivedReadSchema(BaseSchema):
    id: int
    first_name: str
    last_name: str
    requester_id: UUID
    status: str
    created_at: datetime
    updated_at: datetime


class FriendRequestReceivedUpdateSchema(BaseSchema):
    status: Optional[Literal["rejected", "accepted"]]


class FriendRequestCreateSchema(BaseSchema):
    recipient_email: str
