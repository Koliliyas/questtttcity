from datetime import datetime

from pydantic import constr

from src.core.schemas import BaseSchema, CustomEmailStr
from src.db.models.unlock_request import UnlockRequestStatus


class UnlockRequestCreateSchema(BaseSchema):
    email: CustomEmailStr
    reason: constr(min_length=1, max_length=128)
    message: constr(min_length=1, max_length=1024)


class UnlockRequestReadSchema(BaseSchema):
    id: int
    email: str
    reason: str
    status: str
    message: str
    created_at: datetime
    updated_at: datetime


class UnlockRequestUpdateSchema(BaseSchema):
    status: UnlockRequestStatus
