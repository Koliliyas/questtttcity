from api import exceptions as ex

base_responses = [ex.ServerHTTPError]

base_responses_with_auth = [
    ex.AccessTokenExpiredHTTPError,
    ex.InvalidAccessTokenHTTPError,
    ex.MissingAccessTokenHTTPError,
    ex.PermissionDeniedHTTPError,
] + base_responses
