from fastapi import status

from api.exceptions import APIErrorSchema, BaseHTTPError


class MerchNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "MERCH_NOT_FOUND"
    error_schema = APIErrorSchema(
        code=code,
        message="Merch not found.",
    )
