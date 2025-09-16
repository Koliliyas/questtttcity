import aioinject

from core.di._types import Providers
from core.profile.repositories import ProfileRepository
from core.profile.services import ProfileService
from core.user.repositories import UserRepository
from core.user.services import UserService

PROVIDERS: Providers = [
    aioinject.Scoped(UserService),
    aioinject.Scoped(UserRepository),
    aioinject.Scoped(ProfileRepository),
    aioinject.Scoped(ProfileService),
]
