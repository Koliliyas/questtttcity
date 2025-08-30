from api import exceptions as core_api_exc
from api.exceptions import PermissionDeniedHTTPError
from api.modules.chat import exceptions as chat_api_exc
from api.responses import base_responses_with_auth
from api.utils import get_responses

create_chat_responses = get_responses(
    [
        chat_api_exc.ChatWithSelfHTTPError,
        chat_api_exc.RecipientIsBlockedHTTPError,
        chat_api_exc.RecipientNotFoundHTTPError,
        chat_api_exc.ChatBetweenUsersAlreadyExistsHTTPError,
    ]
    + base_responses_with_auth
)
get_messages_responses = get_responses(base_responses_with_auth)

get_chats_responses = get_responses(base_responses_with_auth)

get_messages_for_chat_responses = get_responses(base_responses_with_auth)

delete_message_responses = get_responses(
    [chat_api_exc.MessageNotFoundHTTPError] + base_responses_with_auth
)

delete_chat_responses = get_responses(
    [
        chat_api_exc.ChatNotFoundHTTPError,
        chat_api_exc.ParticipantNotFoundHTTPError,
    ]
    + base_responses_with_auth
)

mark_as_read_responses = get_responses(
    [chat_api_exc.MessageNotFoundHTTPError, PermissionDeniedHTTPError]
    + base_responses_with_auth
)

update_message_responses = get_responses(
    [
        chat_api_exc.MessageNotFoundHTTPError,
        core_api_exc.PermissionDeniedHTTPError,
        core_api_exc.S3ClientHTTPError,
    ]
    + base_responses_with_auth
)
