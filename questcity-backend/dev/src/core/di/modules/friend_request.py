import aioinject

from core.di._types import Providers
from core.friend_request.repositories import FriendRequestRepository
from core.friend_request.services import FriendRequestService

PROVIDERS: Providers = [
    aioinject.Scoped(FriendRequestService),
    aioinject.Scoped(FriendRequestRepository),
]
