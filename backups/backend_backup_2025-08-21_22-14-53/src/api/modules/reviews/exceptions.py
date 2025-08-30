from fastapi import status

from src.api.exceptions import APIErrorSchema, BaseHTTPError


class ReviewAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "REVIEW_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code, message="Review from this user already exists."
    )


class ReviewResponseAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "REVIEW_RESPONSE_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code, message="Review response for this response already exists."
    )


class ReviewNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "REVIEW_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Review not found.")
