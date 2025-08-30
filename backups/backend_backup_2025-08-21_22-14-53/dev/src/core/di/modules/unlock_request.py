import aioinject

from core.di._types import Providers
from core.unlock_request.repositories import UnlockRequestRepository
from core.unlock_request.services import UnlockRequestService

PROVIDERS: Providers = [
    aioinject.Scoped(UnlockRequestRepository),
    aioinject.Scoped(UnlockRequestService),
]
