import aioinject

from src.core.di._types import Providers
from src.core.profile.repositories import ProfileRepository
from src.core.profile.services import ProfileService
from src.core.user.repositories import UserRepository
from src.core.user.services import UserService

PROVIDERS: Providers = [
    aioinject.Scoped(UserService),
    aioinject.Scoped(UserRepository),
    aioinject.Scoped(ProfileRepository),
    aioinject.Scoped(ProfileService),
]
