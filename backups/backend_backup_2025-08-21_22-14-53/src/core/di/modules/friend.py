import aioinject

from src.core.di._types import Providers
from src.core.friend.repositories import FriendRepository
from src.core.friend.services import FriendService

PROVIDERS: Providers = [
    aioinject.Scoped(FriendService),
    aioinject.Scoped(FriendRepository),
]
