from fastapi import status

from src.api.exceptions import APIErrorSchema, BaseHTTPError


class FavoriteAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "FAVORITE_ALREADY_EXISTS"
    error_schema = APIErrorSchema(code=code, message="Favorite already exists.")


class FavoriteNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "FAVORITE_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Favorite does not exist.")
