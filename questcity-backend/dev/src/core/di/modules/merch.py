import aioinject

from core.di._types import Providers
from core.merch.repository import MerchRepository
from core.merch.service import MerchService

PROVIDERS: Providers = [
    aioinject.Scoped(MerchRepository),
    aioinject.Scoped(MerchService),
]
