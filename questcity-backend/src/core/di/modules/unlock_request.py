import aioinject

from src.core.di._types import Providers
from src.core.unlock_request.repositories import UnlockRequestRepository
from src.core.unlock_request.services import UnlockRequestService

PROVIDERS: Providers = [
    aioinject.Scoped(UnlockRequestRepository),
    aioinject.Scoped(UnlockRequestService),
]
