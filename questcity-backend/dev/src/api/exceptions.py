from typing import Protocol

from starlette import status

from core.schemas import BaseSchema


class APIErrorSchema(BaseSchema):
    code: str
    message: str


class HasIdentifierAPIErrorSchema(APIErrorSchema):
    identifier: str
    entity_name: str


class BaseHTTPErrorProtocol(Protocol):
    status_code: int
    error_schema: APIErrorSchema
    code: str


class BaseHTTPError(BaseHTTPErrorProtocol, Exception):
    pass


class EmailAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "EMAIL_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code, message="This email address is already in use."
    )


class UsernameAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "USERNAME_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="This username is already in use.",
    )


class RefreshTokenExpiredHTTPError(BaseHTTPError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "REFRESH_TOKEN_EXPIRED"
    error_schema = APIErrorSchema(
        code=code,
        message="Refresh token has expired.",
    )


class InvalidUserCredentialsHTTPError(BaseHTTPError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "INVALID_USER_CREDENTIALS"
    error_schema = APIErrorSchema(
        code=code,
        message="Incorrect login or password.",
    )


class InactiveUserHTTPError(BaseHTTPError):
    status_code = status.HTTP_403_FORBIDDEN
    code = "INACTIVE_USER"
    error_schema = APIErrorSchema(code=code, message="User is inactive.")


class UnverifiedUserHTTPError(BaseHTTPError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "UNVERIFIED_USER"
    error_schema = APIErrorSchema(code=code, message="User is unverified.")


class InvalidRefreshTokeHTTPError(BaseHTTPError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "INVALID_REFRESH_TOKEN"
    error_schema = APIErrorSchema(code=code, message="Invalid refresh token.")


class AccessTokenExpiredHTTPError(BaseHTTPError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "ACCESS_TOKEN_EXPIRED"
    error_schema = APIErrorSchema(
        code=code,
        message="Access token has expired.",
    )


class InvalidAccessTokenHTTPError(BaseHTTPError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "INVALID_ACCESS_TOKEN"
    error_schema = APIErrorSchema(code=code, message="Invalid access token.")


class MissingAccessTokenHTTPError(BaseHTTPError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "ACCESS_TOKEN_REQUIRED"
    error_schema = APIErrorSchema(
        code=code,
        message="Access token is required.",
    )


class ServerHTTPError(BaseHTTPError):
    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    code = "INTERNAL_SERVER_ERROR"
    error_schema = APIErrorSchema(code=code, message="Internal server error.")


class PermissionDeniedHTTPError(BaseHTTPError):
    status_code = status.HTTP_403_FORBIDDEN
    code = "PERMISSION_DENIED"
    error_schema = APIErrorSchema(
        code=code, message="You don't have permission to access this."
    )


class UserNotFoundForEmailHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "USER_NOT_FOUND_FOR_EMAIL"
    error_schema = APIErrorSchema(
        code=code,
        message="No user found with that email.",
    )


class InvalidEmailCodeHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "INVALID_CODE"
    error_schema = APIErrorSchema(
        code=code,
        message="Invalid confirmation code.",
    )


class EmailCodeExpiredHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "CODE_EXPIRED"
    error_schema = APIErrorSchema(
        code=code,
        message="Confirmation code has expired.",
    )


class InvalidResetPasswordTokenHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "INVALID_RESET_PASSWORD_TOKEN"
    error_schema = APIErrorSchema(
        code=code,
        message="Invalid reset password token.",
    )


class ResetPasswordTokenExpiredError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "RESET_PASSWORD_TOKEN_EXPIRED"
    error_schema = APIErrorSchema(
        code=code, message="Reset password token has expired."
    )


class UserNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "USER_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="User not found.")


class S3ClientHTTPError(BaseHTTPError):
    # TODO: Научить ловить разные исключения от S3 и прокидывать их сюда.
    status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    code = "S3_SERVICE_UNAVAILABLE"
    error_schema = APIErrorSchema(
        code=code,
        message="S3 service unavailable.",
    )


class InvalidFileHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "INVALID_UPDATE_FILE_CONTENT"
    error_schema = APIErrorSchema(
        code=code,
        message="Invalid update file content.",
    )
