from src.api import exceptions as api_exc
from src.api.modules.friend import exceptions as f_api_exc
from src.api.modules.friend_request import exceptions as fr_api_exc
from src.api.responses import base_responses_with_auth
from src.api.utils import get_responses

create_me_friend_request_responses = get_responses(
    [
        fr_api_exc.FriendRequestAlreadyExistsHTTPError,
        fr_api_exc.SelfFriendRequestHTTPError,
    ]
    + base_responses_with_auth
)

get_me_friend_requests_sent_responses = get_responses([] + base_responses_with_auth)

delete_sent_me_friend_request_responses = get_responses(
    [
        fr_api_exc.FriendRequestAlreadyExistsHTTPError(),
        api_exc.PermissionDeniedHTTPError(),
    ]
    + base_responses_with_auth
)

get_me_friend_requests_received_responses = get_responses([] + base_responses_with_auth)

update_me_friend_request_received_responses = get_responses(
    [
        fr_api_exc.FriendRequestNotFoundHTTPError(),
        api_exc.PermissionDeniedHTTPError(),
        f_api_exc.UserNotEligibleForFriendHTTPError(),
        f_api_exc.FriendshipAlreadyExistsHTTPError(),
    ]
    + base_responses_with_auth
)

create_me_friend_request_responses = get_responses(
    [
        fr_api_exc.SelfFriendRequestHTTPError(),
        fr_api_exc.FriendRequestAlreadyExistsHTTPError(),
        fr_api_exc.UserNotEligibleForFriendRequestHTTPError(),
    ]
    + base_responses_with_auth
)
