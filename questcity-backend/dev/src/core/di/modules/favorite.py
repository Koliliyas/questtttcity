import aioinject

from core.di._types import Providers
from core.favorite.repositories import FavoriteRepository
from core.favorite.services import FavoriteService

PROVIDERS: Providers = [
    aioinject.Scoped(FavoriteService),
    aioinject.Scoped(FavoriteRepository),
]
