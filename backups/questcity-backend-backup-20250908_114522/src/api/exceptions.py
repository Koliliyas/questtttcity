from typing import Protocol, Optional

from starlette import status

from src.core.schemas import BaseSchema


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


# === FILE VALIDATION ERRORS ===

class FileTooLargeHTTPError(BaseHTTPError):
    status_code = status.HTTP_413_REQUEST_ENTITY_TOO_LARGE
    code = "FILE_TOO_LARGE"
    
    def __init__(self, actual_size: int, max_size: int):
        self.actual_size = actual_size
        self.max_size = max_size
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"File too large: {actual_size} bytes (max {max_size} bytes)"
        )


class InvalidFileTypeHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "INVALID_FILE_TYPE"
    
    def __init__(self, actual_type: str, allowed_types: list):
        self.actual_type = actual_type
        self.allowed_types = allowed_types
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"Invalid file type: {actual_type} (allowed: {', '.join(allowed_types[:3])}...)"
        )


class SuspiciousFileContentHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "SUSPICIOUS_FILE_CONTENT"
    
    def __init__(self, reason: str):
        self.reason = reason
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"Suspicious file content: {reason}"
        )


class VirusDetectedHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "VIRUS_DETECTED"
    
    def __init__(self, virus_name: str):
        self.virus_name = virus_name
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"Virus detected: {virus_name}"
        )


class EmptyFileHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "EMPTY_FILE"
    error_schema = APIErrorSchema(
        code=code,
        message="File is empty"
    )


class CorruptedFileHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "CORRUPTED_FILE"
    
    def __init__(self, reason: str = "File is corrupted or unreadable"):
        self.reason = reason
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=reason
        )


class ZipBombHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "ZIP_BOMB_DETECTED"
    
    def __init__(self, compression_ratio: float):
        self.compression_ratio = compression_ratio
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"Potential ZIP bomb detected: compression ratio {compression_ratio:.2f}"
        )


class UnsafeFilenameHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "UNSAFE_FILENAME"
    
    def __init__(self, filename: str, reason: str):
        self.filename = filename
        self.reason = reason
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"Unsafe filename '{filename}': {reason}"
        )


class FileValidationHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "FILE_VALIDATION_ERROR"
    
    def __init__(self, message: str, error_code: Optional[str] = None):
        self.error_schema = APIErrorSchema(
            code=error_code or self.code,
            message=message
        )


# === SEARCH SECURITY ERRORS ===

class InvalidSearchTermHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "INVALID_SEARCH_TERM"
    
    def __init__(self, reason: str):
        self.reason = reason
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"Invalid search term: {reason}"
        )


class SuspiciousSearchHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "SUSPICIOUS_SEARCH_PATTERN"
    
    def __init__(self, pattern: str):
        self.pattern = pattern
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"Search contains suspicious pattern: {pattern}"
        )


class SearchTermTooLongHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "SEARCH_TERM_TOO_LONG"
    
    def __init__(self, length: int, max_length: int):
        self.length = length
        self.max_length = max_length
        self.error_schema = APIErrorSchema(
            code=self.code,
            message=f"Search term too long: {length} characters (max {max_length})"
        )
