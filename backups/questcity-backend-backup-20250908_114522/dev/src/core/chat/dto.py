from dataclasses import dataclass
from typing import Optional
from uuid import UUID


@dataclass
class MessageSendDTO:
    text: str
    author_id: UUID
    chat_id: int
    file_url: Optional[str]


@dataclass
class MessageIsReadDTO:
    is_read: bool
