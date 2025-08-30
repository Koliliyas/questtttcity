from api.modules.user.schemas import PasswordSchema
from core.schemas import BaseSchema, CustomEmailStr


class TokensReadSchema(BaseSchema):
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"


class TokensRefreshSchema(BaseSchema):
    refresh_token: str


class RefreshTokenDestroy(BaseSchema):
    refresh_token: str


class VerifyEmailSchema(BaseSchema):
    email: CustomEmailStr
    code: int


class ResetPasswordTokenReadSchema(BaseSchema):
    token: str


class EmailResetPasswordSchema(BaseSchema):
    email: CustomEmailStr


class ResetPasswordSchema(PasswordSchema):
    pass
