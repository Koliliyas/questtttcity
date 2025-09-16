import aioinject

from src.core.di._types import Providers
from src.core.merch.repository import MerchRepository
from src.core.merch.service import MerchService

PROVIDERS: Providers = [
    aioinject.Scoped(MerchRepository),
    aioinject.Scoped(MerchService),
]
