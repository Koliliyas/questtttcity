import aioinject

from core.di._types import Providers
from core.friend.repositories import FriendRepository
from core.friend.services import FriendService

PROVIDERS: Providers = [
    aioinject.Scoped(FriendService),
    aioinject.Scoped(FriendRepository),
]
