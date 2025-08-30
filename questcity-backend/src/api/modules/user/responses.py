from src.api import exceptions as api_ex
from src.api.responses import base_responses_with_auth
from src.api.utils import get_responses

get_me_responses = get_responses(base_responses_with_auth)

update_me_responses = get_responses(
    [api_ex.UsernameAlreadyExistsHTTPError] + base_responses_with_auth
)

verify_email_change_code_responses = get_responses(
    [api_ex.InvalidEmailCodeHTTPError, api_ex.EmailCodeExpiredHTTPError]
    + base_responses_with_auth
)

get_users_responses = get_responses(base_responses_with_auth)

get_user_responses = get_responses(
    [api_ex.UserNotFoundHTTPError] + base_responses_with_auth
)

create_users_responses = get_responses(
    [api_ex.EmailAlreadyExistsHTTPError, api_ex.UsernameAlreadyExistsHTTPError]
    + base_responses_with_auth
)

change_password_responses = get_responses(
    [api_ex.InvalidUserCredentialsHTTPError] + base_responses_with_auth
)
