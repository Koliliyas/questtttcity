import aioinject

from src.core.di._types import Providers
from src.core.friend_request.repositories import FriendRequestRepository
from src.core.friend_request.services import FriendRequestService

PROVIDERS: Providers = [
    aioinject.Scoped(FriendRequestService),
    aioinject.Scoped(FriendRequestRepository),
]
