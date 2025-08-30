import aioinject
from fastapi_mail import FastMail

from core.authentication.repositories import (AccessTokenRepository,
                                              EmailVerificationCodeRepository,
                                              RefreshTokenRepository,
                                              ResetPasswordTokenRepository)
from core.authentication.services import (
    AuthenticationService, ChangeEmailVerificationService,
    RegistrationEmailVerificationService,
    ResetPasswordEmailVerificationService)
from core.di._types import Providers
from settings import MailSettings


async def create_fast_mail(settings: MailSettings) -> FastMail:
    return FastMail(settings)


PROVIDERS: Providers = [
    aioinject.Scoped(create_fast_mail),
    aioinject.Scoped(RefreshTokenRepository),
    aioinject.Scoped(AccessTokenRepository),
    aioinject.Scoped(EmailVerificationCodeRepository),
    aioinject.Scoped(ResetPasswordTokenRepository),
    aioinject.Scoped(AuthenticationService),
    aioinject.Scoped(ResetPasswordEmailVerificationService),
    aioinject.Scoped(RegistrationEmailVerificationService),
    aioinject.Scoped(ChangeEmailVerificationService),
]
