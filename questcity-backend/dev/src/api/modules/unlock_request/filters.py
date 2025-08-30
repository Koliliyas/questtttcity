from typing import Optional

from fastapi import Query
from fastapi_filter.contrib.sqlalchemy import Filter
from pydantic import Field

from db.models.unlock_request import UnlockRequest, UnlockRequestStatus


class UnlockRequestFilter(Filter):
    email: Optional[str] = None
    reason: Optional[str] = None
    status__in: Optional[list[UnlockRequestStatus]] = None
    order_by: Optional[list[str]] = Field(
        Query(
            description="You can change the direction of the sorting (asc or desc) by prefixing with - or + (Optional, it's the default behavior if omitted)."
        )
    )

    class Constants(Filter.Constants):
        model = UnlockRequest
