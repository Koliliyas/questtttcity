import aioinject

from src.core.di._types import Providers
from src.core.favorite.repositories import FavoriteRepository
from src.core.favorite.services import FavoriteService

PROVIDERS: Providers = [
    aioinject.Scoped(FavoriteService),
    aioinject.Scoped(FavoriteRepository),
]
