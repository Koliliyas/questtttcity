class RefreshTokenExpiredError(Exception):
    pass


class InvalidRefreshTokeError(Exception):
    pass


class InvalidAccessTokenError(Exception):
    pass


class InvalidUserCredentialsError(Exception):
    pass


class InactiveUserError(Exception):
    pass


class UnverifiedUserError(Exception):
    pass


class AccessTokenExpiredError(Exception):
    pass


class UserNotFoundForEmailError(Exception):
    pass


class InvalidEmailCodeError(Exception):
    pass


class EmailCodeExpiredError(Exception):
    pass


class InvalidResetPasswordTokenError(Exception):
    pass


class ResetPasswordTokenExpiredError(Exception):
    pass
