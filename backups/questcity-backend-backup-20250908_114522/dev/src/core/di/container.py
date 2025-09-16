import functools
import itertools
from collections.abc import Iterable

import aioinject
from pydantic_settings import BaseSettings

from core.di.modules import (authentication, chat, default, favorite, friend,
                             friend_request, merch, quest, unlock_request,
                             user)
from settings import (ApplicationSettings, AuthJWTSettings, DatabaseSettings,
                      EmailVerificationSettings, MailSettings, S3Settings,
                      get_settings)
from src.db.dependencies import create_session

MODULES = [
    authentication.PROVIDERS,
    user.PROVIDERS,
    unlock_request.PROVIDERS,
    default.PROVIDERS,
    quest.PROVIDERS,
    friend_request.PROVIDERS,
    friend.PROVIDERS,
    chat.PROVIDERS,
    merch.PROVIDERS,
    favorite.PROVIDERS,
]


SETTINGS = (
    ApplicationSettings,
    DatabaseSettings,
    AuthJWTSettings,
    MailSettings,
    EmailVerificationSettings,
    S3Settings,
)


def _register_settings(
    container: aioinject.Container,
    *,
    settings_classes: Iterable[type[BaseSettings]],
) -> None:
    for settings_cls in settings_classes:
        factory = functools.partial(get_settings, settings_cls)
        container.register(aioinject.Singleton(factory, type_=settings_cls))


@functools.lru_cache
def create_container() -> aioinject.Container:
    container = aioinject.Container()
    container.register(aioinject.Scoped(create_session))

    for provider in itertools.chain.from_iterable(MODULES):
        container.register(provider)

    _register_settings(container, settings_classes=SETTINGS)

    return container
