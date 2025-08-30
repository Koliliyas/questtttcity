from src.api.modules.unlock_request import exceptions as ur_exc
from src.api.responses import base_responses, base_responses_with_auth
from src.api.utils import get_responses

create_unlock_request_responses = get_responses(
    [
        ur_exc.PendingUnlockRequestExistsHTTPError,
        ur_exc.ActiveUserHTTPError,
    ]
    + base_responses
)

get_unlock_requests_responses = get_responses(base_responses_with_auth)
get_unlock_request_responses = get_responses(
    [ur_exc.UnlockRequestNotFoundHTTPError] + base_responses_with_auth
)
update_unlock_request_responses = get_responses(
    [ur_exc.UnlockRequestNotFoundHTTPError] + base_responses_with_auth
)
