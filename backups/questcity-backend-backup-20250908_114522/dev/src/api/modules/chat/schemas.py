import base64
from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import Field, field_validator

from core.schemas import BaseSchema


class ProfileSchema(BaseSchema):
    avatar_url: Optional[str] = Field(None, alias="image")


class ParticipantSchema(BaseSchema):
    id: UUID
    full_name: str
    profile: ProfileSchema


class MessageRequestSchema(BaseSchema):
    text: str = Field(min_length=1)
    file_url: Optional[str] = Field(None, alias="file")

    @field_validator("file_url")
    def file_data_is_valid_base64(cls, value: str) -> str:
        if value is not None:
            if value.startswith("data:"):
                _, value = value.split(",", 1)

            try:
                base64.b64decode(value, validate=True)
            except (ValueError, TypeError) as exception:
                raise ValueError(
                    "File data is not a valid base64 string"
                ) from exception

        return value


class MessageResponseSchema(BaseSchema):
    id: int
    text: str
    file_url: Optional[str] = Field(None, alias="file")
    chat_id: int
    author_id: UUID
    created_at: datetime
    updated_at: datetime

    @field_validator("author_id")
    def autor_id_to_str(cls, value: UUID) -> str:
        return str(value)

    @field_validator("created_at")
    def datetime_to_isoformat(cls, value: datetime) -> str:
        return value.isoformat()


# Chat preview:
class MessagePreviewSchema(BaseSchema):
    id: int
    text: str
    file_url: Optional[str] = Field(None, alias="file")
    created_at: datetime
    is_read: bool


class ChatPreviewResponseSchema(BaseSchema):
    id: int
    unread_count: int
    recipient: ParticipantSchema
    message: Optional[MessagePreviewSchema] = Field(None, alias="last_message")


# Chat with messages:
class MessageInChatResponseSchema(MessagePreviewSchema):
    id: int
    text: str
    file_url: Optional[str] = Field(None, alias="file")
    created_at: datetime

    author: ParticipantSchema


class ChatResponseSchema(BaseSchema):
    id: int
    messages: list[MessageInChatResponseSchema] = Field(default_factory=list)
    participants: list[ParticipantSchema]
    created_at: datetime


class MessageIsReadRequestSchema(BaseSchema):
    is_read: bool


class MessageUpdateRequestSchema(MessageRequestSchema):
    text: Optional[str] = Field(None, min_length=1)
