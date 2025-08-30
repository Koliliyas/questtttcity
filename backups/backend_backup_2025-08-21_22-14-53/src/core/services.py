from botocore.exceptions import ClientError
from fastapi import BackgroundTasks
from fastapi_mail import FastMail, MessageSchema, MessageType

from src.core.dto import EmailMessageDTO
from src.core.repositories import S3Repository


class BaseService:
    def __init__(self, s3: S3Repository) -> None:
        self._s3 = s3
        self.temporary_files_links = []
        self.old_files_links = []

    async def clear_files_after_fail(self) -> None:
        for link in self.temporary_files_links:
            try:
                await self._s3.delete_file(link)
            except ClientError:
                # FIXME: добавить логирование исключения
                pass

    async def clear_old_files_after(self) -> None:
        for link in self.old_files_links:
            try:
                await self._s3.delete_file(link)
            except ClientError:
                # FIXME: добавить логирование исключения
                pass


class EmailSenderService:
    def __init__(self, mail_service: FastMail):
        self._mail_service = mail_service

    async def send_message(
        self, message_dto: EmailMessageDTO, background_tasks: BackgroundTasks
    ):
        message = MessageSchema(
            subject=message_dto.subject,
            recipients=message_dto.recipients,
            body=message_dto.body,
            subtype=MessageType.plain,
        )

        background_tasks.add_task(self._mail_service.send_message, message)
