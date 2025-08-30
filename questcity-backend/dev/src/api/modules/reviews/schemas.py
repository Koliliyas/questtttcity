from datetime import datetime
from uuid import UUID

from pydantic import model_validator

from core.schemas import BaseSchema


class CreateReviewSchema(BaseSchema):
    text: str
    rating: int
    quest_id: int

    @model_validator(mode="after")
    def check_rating_range(self) -> "CreateReviewSchema":
        if not (1 <= self.rating <= 5):
            raise ValueError("Rating should be 1 to 5")
        return self


class ReadProfileForReviewSchema(BaseSchema):
    avatar_url: str | None


class ReadUserForReviewSchema(BaseSchema):
    id: UUID
    first_name: str
    last_name: str
    profile: ReadProfileForReviewSchema


class ReadManagerResponseSchema(BaseSchema):
    id: int
    text: str
    created_at: datetime
    user: ReadUserForReviewSchema


class ReadReviewSchema(BaseSchema):
    id: int
    text: str
    user: ReadUserForReviewSchema
    rating: int
    created_at: datetime
    manager_response: ReadManagerResponseSchema | None = None


class CreateReviewResponseSchema(BaseSchema):
    text: str
