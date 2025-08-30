import datetime
import uuid
from typing import Annotated

from sqlalchemy import Integer, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import mapped_column

uuid_pk = Annotated[
    uuid.UUID, mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
]
int32_pk = Annotated[int, mapped_column(Integer, primary_key=True, autoincrement=True)]

_created_at = Annotated[
    datetime.datetime,
    mapped_column(server_default=text("TIMEZONE('utc', now())"), nullable=False),
]
_updated_at = Annotated[
    datetime.datetime,
    mapped_column(
        server_default=text("TIMEZONE('utc', now())"),
        onupdate=datetime.datetime.utcnow,
    ),
]
