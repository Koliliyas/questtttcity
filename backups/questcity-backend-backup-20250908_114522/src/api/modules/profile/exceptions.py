from fastapi import status

from src.api.exceptions import APIErrorSchema, BaseHTTPError


class ProfileNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "PROFILE_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Profile not found.")
