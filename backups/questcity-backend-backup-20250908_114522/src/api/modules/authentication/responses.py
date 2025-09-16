from src.api import exceptions as ex
from src.api.responses import base_responses
from src.api.utils import get_responses

refresh_token_responses = get_responses(
    [
        ex.RefreshTokenExpiredHTTPError,
        ex.InvalidRefreshTokeHTTPError,
    ]
    + base_responses
)

login_responses = get_responses(
    [
        ex.InvalidUserCredentialsHTTPError,
        ex.InactiveUserHTTPError,
        ex.UnverifiedUserHTTPError,
    ]
    + base_responses
)

register_responses = get_responses(
    [
        ex.EmailAlreadyExistsHTTPError,
        ex.UsernameAlreadyExistsHTTPError,
    ]
    + base_responses
)

logout_responses = get_responses([ex.InvalidRefreshTokeHTTPError] + base_responses)

reset_password_responses = get_responses(
    [
        ex.UserNotFoundForEmailHTTPError,
        ex.InactiveUserHTTPError,
        ex.UnverifiedUserHTTPError,
    ]
    + base_responses
)

reset_password_by_token_responses = get_responses(
    [
        ex.InvalidResetPasswordTokenHTTPError,
        ex.InvalidResetPasswordTokenHTTPError,
        ex.UserNotFoundForEmailHTTPError,
    ]
    + base_responses
)

verify_reset_password_responses = get_responses(
    [ex.InvalidEmailCodeHTTPError, ex.EmailCodeExpiredHTTPError] + base_responses
)

verify_register_responses = get_responses(
    [
        ex.InvalidEmailCodeHTTPError,
        ex.EmailCodeExpiredHTTPError,
        ex.UserNotFoundForEmailHTTPError,
    ]
    + base_responses
)
