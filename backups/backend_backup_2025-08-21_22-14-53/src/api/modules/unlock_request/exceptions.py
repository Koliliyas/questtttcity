from fastapi import status

from src.api.exceptions import APIErrorSchema, BaseHTTPError


class PendingUnlockRequestExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "PENDING_UNLOCK_REQUEST_EXISTS"
    error_schema = APIErrorSchema(
        code=code, message="A pending unlock request already exists for this email."
    )


class ActiveUserHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "USER_ALREADY_ACTIVE"
    error_schema = APIErrorSchema(
        code=code, message="User is already active. Unlock request is not allowed."
    )


class UnlockRequestNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "UNLOCK_REQUEST_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Unlock request not found.")
