import copy
from uuid import UUID

from botocore.exceptions import ClientError
from fastapi import WebSocket
from result import Err

from src.api.modules.chat.schemas import (MessageResponseSchema,
                                      MessageUpdateRequestSchema)
from src.core.chat import exceptions as exc
from src.core.chat.dto import MessageIsReadDTO, MessageSendDTO
from src.core.chat.exceptions import (ChatBetweenUsersAlreadyExist,
                                  ChatNotFoundException, ChatWithSelfException,
                                  MessageNotFoundException)
from src.core.chat.repositories import ChatRepository, MessageRepository
from src.core.exceptions import PermissionDeniedError, S3ServiceClientException
from src.core.repositories import S3Repository
from src.core.services import BaseService
from src.core.user.exceptions import UserNotFoundError
from src.core.user.repositories import UserRepository
from src.db.models.chat import Chat, Message
from src.db.models.user import User


class ChatService(BaseService):
    def __init__(
        self,
        message_repository: MessageRepository,
        chat_repository: ChatRepository,
        user_repository: UserRepository,
        s3: S3Repository,
    ) -> None:
        super().__init__(s3)
        self._message_repository = message_repository
        self._chat_repository = chat_repository
        self._user_repository = user_repository

    async def add_chat(
        self,
        user: User,
        recipient_id: UUID,
    ) -> User | Err[ChatWithSelfException | UserNotFoundError | PermissionDeniedError]:
        if user == recipient_id:
            return Err(ChatWithSelfException())

        recipient = await self._user_repository.get_by_pk(recipient_id)
        if recipient is None:
            return Err(UserNotFoundError())

        if not recipient.is_active and user.role < 1:
            return Err(PermissionDeniedError())

        chat = await self._chat_repository.get_between(user, recipient.id)

        if chat is not None:
            return Err(ChatBetweenUsersAlreadyExist())

        chat = await self._chat_repository.create_new_chat(
            [await self._user_repository.get_by_pk(pk) for pk in [user, recipient.id]]
        )

        return chat

    async def send_message(
        self, dto: MessageSendDTO
    ) -> Err[ChatNotFoundException] | Message:
        chat = await self._chat_repository.get_by_oid(dto.chat_id)

        if chat is None:
            return Err(ChatNotFoundException())

        if dto.file_url is not None:
            try:
                dto.file_url = await self._s3.upload_file(
                    f"chat_{dto.chat_id}",
                    dto.file_url,
                )
                self.temporary_files_links.append(dto.file_url)
            except ClientError:
                return Err(S3ServiceClientException())

        message = await self._message_repository.add_message(dto)

        return message

    async def get_chat_between_users(
        self,
        first_user_id: UUID,
        second_user_id: UUID,
    ) -> Chat | Err[exc.ChatNotFoundException]:
        chat = await self._chat_repository.get_between(
            first_user_id,
            second_user_id,
        )
        if chat is None:
            return Err(exc.ChatNotFoundException())

        return chat

    async def get_user_chats(self, user_id: UUID) -> list[Chat]:
        chats = list(await self._chat_repository.get_all_chat_for_user(user_id))
        copy_chats = copy.deepcopy(chats)

        for chat in copy_chats:
            chat.participants.remove(
                next(user for user in chat.participants if user.id == user_id)
            )

        return copy_chats

    async def get_chat_with_messages(
        self,
        chat_id: int,
    ) -> Err[ChatNotFoundException] | Chat:
        chat = await self._chat_repository.get_chat_with_messages(chat_id)

        if not chat:
            return Err(ChatNotFoundException())

        return chat

    async def remove_message_in_chat(self, message_id: int) -> None | Err:
        message = await self._message_repository.get_by_oid(message_id)

        if message.file_url is not None:
            self.old_files_links.append(message.file_url)

        if message is None:
            return Err(MessageNotFoundException())

        await self._message_repository.delete(message)

    async def mark_message_as_read(
        self,
        message_id: int,
        user: User,
        dto: MessageIsReadDTO,
    ):
        message = await self._message_repository.get_by_oid(message_id)

        if message is None:
            return Err(MessageNotFoundException())

        chat = await self._chat_repository.get_by_oid(message.chat_id)

        if message not in chat.messages:
            return Err(MessageNotFoundException())

        if (
            message.author_id == user.id
            or next(
                (
                    participant
                    for participant in chat.participants
                    if participant.id == user.id
                ),
                None,
            )
            is None
        ):
            return Err(PermissionDeniedError())

        await self._message_repository.update(message, dto)

        return message

    async def update_message(
        self,
        message_id: int,
        data: MessageUpdateRequestSchema,
        user: User,
    ):
        message = await self._message_repository.get_by_oid(message_id)

        if message is None:
            return Err(MessageNotFoundException())

        chat = await self._chat_repository.get_by_oid(message.chat_id)

        if message not in chat.messages:
            return Err(MessageNotFoundException())

        if (
            message.author_id != user.id
            or next(
                (
                    participant
                    for participant in chat.participants
                    if participant.id == user.id
                ),
                None,
            )
            is None
        ):
            return Err(PermissionDeniedError())

        if data.file_url is not None:
            self.old_files_links.append(message.file_url)
            try:
                data.file_url = await self._s3.upload_file(
                    f"chat_{message.chat_id}",
                    data.file_url,
                )
                self.temporary_files_links.append(data.file_url)
            except ClientError:
                return Err(S3ServiceClientException())

        updated_message = await self._message_repository.update_message(
            message,
            data,
        )
        return updated_message


class WebSocketConnectionService:
    def __init__(self) -> None:
        self._active_connections: dict[int, dict[UUID, WebSocket]] = {}

    async def connect(
        self,
        websocket: WebSocket,
        chat_id: int,
        user_id: UUID,
    ) -> None:
        await websocket.accept()

        if chat_id not in self._active_connections:
            self._active_connections[chat_id] = {}

        self._active_connections[chat_id][user_id] = websocket

    async def disconnect(self, chat_id: int, user_id: UUID) -> None:
        if chat_id in self._active_connections:
            self._active_connections[chat_id].pop(user_id, None)

            if not self._active_connections[chat_id]:
                self._active_connections.pop(chat_id)

    async def broadcast_to_chat(
        self,
        message: MessageResponseSchema,
    ):
        if message.chat_id in self._active_connections:
            for connection in self._active_connections[message.chat_id].values():
                await connection.send_json(message.model_dump())
