import aioinject

from src.core.chat.repositories import ChatRepository, MessageRepository
from src.core.chat.services import ChatService, WebSocketConnectionService
from src.core.di._types import Providers

PROVIDERS: Providers = [
    aioinject.Scoped(MessageRepository),
    aioinject.Scoped(ChatRepository),
    aioinject.Scoped(ChatService),
    aioinject.Singleton(WebSocketConnectionService),
]
