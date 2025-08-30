import aioinject

from core.chat.repositories import ChatRepository, MessageRepository
from core.chat.services import ChatService, WebSocketConnectionService
from core.di._types import Providers

PROVIDERS: Providers = [
    aioinject.Scoped(MessageRepository),
    aioinject.Scoped(ChatRepository),
    aioinject.Scoped(ChatService),
    aioinject.Singleton(WebSocketConnectionService),
]
