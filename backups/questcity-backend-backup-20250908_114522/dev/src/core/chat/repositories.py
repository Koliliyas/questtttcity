from dataclasses import asdict
from typing import Sequence
from uuid import UUID

from fastapi.encoders import jsonable_encoder
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload, selectinload

from api.modules.chat.schemas import MessageUpdateRequestSchema
from core.chat.dto import MessageSendDTO
from core.repositories import BaseSQLAlchemyRepository
from db.models import Chat, ChatParticipant, Message, Profile, User


class MessageRepository(BaseSQLAlchemyRepository[Message]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Message)

    async def add_message(self, dto: MessageSendDTO) -> Message:
        self._session.add(message := self._model(**asdict(dto)))
        await self._session.flush()
        await self._session.refresh(message)
        return message

    async def update_message(
        self,
        obj: Message,
        data: MessageUpdateRequestSchema,
    ) -> Message:
        update_data_dict = data.model_dump(
            exclude_none=True,
            exclude_unset=True,
        )

        for field in jsonable_encoder(obj):
            if field in update_data_dict:
                setattr(obj, field, update_data_dict[field])

        await self._session.flush()
        await self._session.refresh(obj)
        return obj


class ChatRepository(BaseSQLAlchemyRepository[Chat]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Chat)

    async def create_new_chat(self, users: list[User]) -> Chat:
        self._session.add(new_chat := Chat())
        new_chat.participants.extend(users)
        await self._session.flush()
        await self._session.refresh(new_chat)
        return new_chat

    async def get_between(
        self,
        first_user_id: UUID,
        second_user_id: UUID,
    ) -> Chat | None:
        return await self._session.scalar(
            select(self._model)
            .join(ChatParticipant)
            .where(ChatParticipant.user_id.in_([first_user_id, second_user_id]))
        )

    async def get_all_chat_for_user(self, user_id: UUID) -> Sequence[Chat]:
        results = await self._session.execute(
            select(self._model)
            .join(ChatParticipant)
            .where(ChatParticipant.user_id == user_id)
            .options(
                joinedload(self._model.participants)
                .load_only(User.id, User.full_name)
                .joinedload(User.profile)
                .load_only(Profile.avatar_url)
            )
            .options(selectinload(self._model.messages))
        )
        return results.unique().scalars().all()

    async def get_chat_with_messages(self, chat_id: int) -> Chat | None:
        return await self._session.scalar(
            select(self._model)
            .where(self._model.id == chat_id)
            .options(
                joinedload(self._model.participants)
                .load_only(User.id, User.full_name)
                .joinedload(User.profile)
                .load_only(Profile.avatar_url)
            )
            .options(
                selectinload(self._model.messages)
                .joinedload(Message.author)
                .load_only(User.full_name)
                .joinedload(User.profile)
                .load_only(Profile.avatar_url)
            )
        )
