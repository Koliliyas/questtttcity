import asyncio
from typing import assert_never
from uuid import UUID

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect, status
from result import Err

from api import exceptions as core_api_exc
from api.modules.chat import exceptions as chat_api_exc
from api.modules.chat import responses
from api.modules.chat.schemas import (ChatPreviewResponseSchema,
                                      ChatResponseSchema,
                                      MessageInChatResponseSchema,
                                      MessageIsReadRequestSchema,
                                      MessagePreviewSchema,
                                      MessageRequestSchema,
                                      MessageResponseSchema,
                                      ParticipantSchema)
from core import exceptions as core_exc
from core.authentication.dependencies import get_user_with_role
from core.chat import exceptions as chat_exc
from core.chat.dto import MessageIsReadDTO, MessageSendDTO
from core.chat.services import ChatService, WebSocketConnectionService
from core.user.exceptions import UserNotFoundError
from db.models import User

router = APIRouter()


@router.post(
    "/{recipient_id}",
    status_code=status.HTTP_201_CREATED,
    response_model=ChatResponseSchema,
    responses=responses.create_chat_responses,
)
@inject
async def create_chat(
    recipient_id: UUID,
    chat_service: Injected[ChatService],
    user: User = Depends(get_user_with_role("user")),
):
    chat = await chat_service.add_chat(user.id, recipient_id)

    if isinstance(chat, Err):
        match chat.err_value:
            case chat_exc.ChatWithSelfException():
                raise chat_api_exc.ChatWithSelfHTTPError()
            case chat_exc.ChatBetweenUsersAlreadyExist():
                raise chat_api_exc.ChatBetweenUsersAlreadyExistsHTTPError()
            case UserNotFoundError():
                raise chat_api_exc.RecipientNotFoundHTTPError()
            case core_exc.PermissionDeniedError():
                raise chat_api_exc.RecipientIsBlockedHTTPError()
            case _ as never:
                assert_never(never)

    response = ChatResponseSchema(
        id=chat.id,
        messages=chat.messages,
        created_at=chat.created_at,
        participants=ParticipantSchema.model_validate_list(chat.participants),
    )

    return response


@router.get(
    "/me",
    response_model=list[ChatPreviewResponseSchema],
    response_model_exclude_none=True,
    responses=responses.get_chats_responses,
)
@inject
async def get_all_chats_for_user(
    chat_service: Injected[ChatService],
    user: User = Depends(get_user_with_role("user")),
):
    chats = await chat_service.get_user_chats(user.id)
    return [
        ChatPreviewResponseSchema(
            id=chat.id,
            unread_count=len(
                [
                    message
                    for message in chat.messages
                    if message.author_id != user.id and not message.is_read
                ]
            ),
            recipient=ParticipantSchema.model_validate(*chat.participants),
            message=MessagePreviewSchema.model_validate(chat.messages[0])
            if chat.messages
            else None,
        )
        for chat in chats
    ]


@router.get(
    "/{chat_id}",
    response_model=ChatResponseSchema,
    responses=responses.get_messages_for_chat_responses,
)
@inject
async def get_chat_between_users(
    chat_id: int,
    chat_service: Injected[ChatService],
    user: User = Depends(get_user_with_role("user")),
):
    chat = await chat_service.get_chat_with_messages(chat_id)

    if isinstance(chat, Err):
        match chat.err_value:
            case chat_exc.ChatNotFoundException():
                raise chat_api_exc.ChatNotFoundHTTPError()

    return ChatResponseSchema(
        id=chat.id,
        created_at=chat.created_at,
        participants=ParticipantSchema.model_validate_list(chat.participants),
        messages=MessageInChatResponseSchema.model_validate_list(chat.messages),
    )


@router.post(
    "/messages/{chat_id}",
    response_model=MessageResponseSchema,
    response_model_exclude_none=True,
    responses=responses.get_messages_responses,
    status_code=status.HTTP_201_CREATED,
)
@inject
async def send_message_in_chat(
    chat_id: int,
    message: MessageRequestSchema,
    chat_service: Injected[ChatService],
    connection_service: Injected[WebSocketConnectionService],
    user: User = Depends(get_user_with_role("user")),
):
    message = await chat_service.send_message(
        MessageSendDTO(
            text=message.text,
            file_url=message.file_url,
            author_id=user.id,
            chat_id=chat_id,
        )
    )

    if isinstance(message, Err):
        if chat_service.temporary_files_links:
            await chat_service.clear_files_after_fail()

        match message.err_value:
            case chat_exc.ChatNotFoundException():
                raise chat_api_exc.ChatNotFoundHTTPError()
            case core_exc.S3ServiceClientException():
                raise core_api_exc.S3ClientHTTPError()

    await connection_service.broadcast_to_chat(
        MessageResponseSchema.model_validate(message)
    )
    return message


@router.delete(
    "/messages/{message_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=responses.delete_message_responses,
)
@inject
async def delete_message_in_chat(
    message_id: int,
    chat_service: Injected[ChatService],
    user: User = Depends(get_user_with_role("user")),
):
    result = await chat_service.remove_message_in_chat(message_id)

    if isinstance(result, Err):
        if result.err_value == chat_exc.MessageNotFoundException():
            raise chat_api_exc.MessageNotFoundHTTPError()

    if chat_service.old_files_links:
        await chat_service.clear_old_files_after()


@router.patch(
    "/messages/{message_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=responses.mark_as_read_responses,
)
@inject
async def mark_message_as_read(
    message_id: int,
    request_data: MessageIsReadRequestSchema,
    chat_service: Injected[ChatService],
    user: User = Depends(get_user_with_role("user")),
):
    message = await chat_service.mark_message_as_read(
        message_id,
        user,
        MessageIsReadDTO(**request_data.model_dump()),
    )

    if isinstance(message, Err):
        match message.err_value:
            case chat_exc.MessageNotFoundException():
                raise chat_api_exc.MessageNotFoundHTTPError()
            case core_exc.PermissionDeniedError():
                raise core_api_exc.PermissionDeniedHTTPError()


@router.patch(
    "/messages/update-content/{message_id}",
    response_model=MessageResponseSchema,
    responses=responses.update_message_responses,
)
@inject
async def update_content_in_message(
    message_id: int,
    request_data: MessageRequestSchema,
    chat_service: Injected[ChatService],
    user: User = Depends(get_user_with_role("user")),
):
    message = await chat_service.update_message(message_id, request_data, user)

    if isinstance(message, Err):
        if chat_service.temporary_files_links:
            await chat_service.clear_files_after_fail()

        match message.err_value:
            case chat_exc.MessageNotFoundException():
                raise chat_api_exc.MessageNotFoundHTTPError()
            case core_exc.PermissionDeniedError():
                raise core_api_exc.PermissionDeniedHTTPError()
            case core_exc.S3ServiceClientException():
                raise core_api_exc.S3ClientHTTPError()
            case _ as never:
                assert_never(never)

    if chat_service.old_files_links:
        await chat_service.clear_old_files_after()

    return message


@router.websocket("/{chat_id}/{user_id}")
@inject
async def chat_websocket_endpoint(
    websocket: WebSocket,
    ws_service: Injected[WebSocketConnectionService],
    chat_id: int,
    user_id: UUID,
):
    await ws_service.connect(websocket, chat_id, user_id)

    try:
        while True:
            await asyncio.sleep(1)
    except WebSocketDisconnect:
        await ws_service.disconnect(chat_id, user_id)
