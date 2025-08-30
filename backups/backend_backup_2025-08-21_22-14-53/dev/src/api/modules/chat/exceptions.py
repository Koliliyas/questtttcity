from fastapi import status

from api.exceptions import APIErrorSchema, BaseHTTPError


class ChatNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "CHAT_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Chat not found.")


class ChatWithSelfHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "CANT_CHAT_WITH_SELF"
    error_schema = APIErrorSchema(
        code=code,
        message="Can't chat with yourself.",
    )


class RecipientNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "RECIPIENT_NOT_FOUND"
    error_schema = APIErrorSchema(
        code=code,
        message="Recipient not found.",
    )


class RecipientIsBlockedHTTPError(BaseHTTPError):
    status_code = status.HTTP_403_FORBIDDEN
    code = "RECIPIENT_IS_BLOCKED"
    error_schema = APIErrorSchema(
        code=code,
        message="Recipient is blocked.",
    )


class ChatBetweenUsersAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "CHAT_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Chat between users already exists.",
    )


class MessageNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "MESSAGE_NOT_FOUND"
    error_schema = APIErrorSchema(
        code=code,
        message="Message not found.",
    )


class ParticipantNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "PARTICIPANT_NOT_FOUND"
    error_schema = APIErrorSchema(
        code=code,
        message="Participant in chat not found.",
    )
