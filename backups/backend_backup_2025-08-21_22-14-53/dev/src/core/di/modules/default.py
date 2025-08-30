import aioinject

from core.di._types import Providers
from core.repositories import S3Repository, create_s3_client
from core.services import EmailSenderService

PROVIDERS: Providers = [
    aioinject.Scoped(EmailSenderService),
    aioinject.Scoped(create_s3_client),
    aioinject.Scoped(S3Repository),
]
