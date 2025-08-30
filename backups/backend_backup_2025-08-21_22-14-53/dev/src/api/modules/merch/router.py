from typing import Annotated

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, BackgroundTasks, Depends, Form, status

from api.modules.merch.responses import create_order_responses
from core.authentication.dependencies import get_user_with_role
from core.dto import EmailMessageDTO
from core.merch.service import MerchService
from core.services import EmailSenderService
from core.user.services import UserService
from db.models.user import User

router = APIRouter()


@router.post(
    "/{id}/order",
    status_code=status.HTTP_202_ACCEPTED,
    responses=create_order_responses,
)
@inject
async def create_order(
    id: int,
    address: Annotated[str, Form()],
    email_sender_service: Injected[EmailSenderService],
    user_service: Injected[UserService],
    merch_service: Injected[MerchService],
    background_tasks: BackgroundTasks,
    user: User = Depends(get_user_with_role("user")),
):
    emails = await user_service.get_staff_emails()

    merch = await merch_service.get_merch(id)

    message_to_staff = EmailMessageDTO(
        subject=f"Request for order merch with id {id}",
        recipients=[*emails],
        body=(
            f"The user '{user.username}' has ordered merch!\n"
            f"Merch {id}:\n"
            f"- Description: {merch.description};\n"
            f"- Price: {merch.price}.\n\n"
            f"From user:\n"
            f"- Fullname: {user.full_name};\n"
            f"- Email: {user.email};\n"
            f"- Delivery address: {address}."
        ),
    )

    await email_sender_service.send_message(
        message_dto=message_to_staff,
        background_tasks=background_tasks,
    )

    confirm_message_to_user = EmailMessageDTO(
        subject="Oreder for review.",
        recipients=[user.email],
        body=(
            "Your order for purchasing merch has been sent to our staff for review. Stay in touch - our manager will contact you.\n\n"
            f"Details:\n"
            f"Merch:\n"
            f"- Description: {merch.description};\n"
            f"- Price: {merch.price}.\n\n"
            f"Your info:\n"
            f"- Fullname: {user.full_name};\n"
            f"- Email: {user.email};\n"
            f"- Delivery address: {address}."
        ),
    )

    await email_sender_service.send_message(
        message_dto=confirm_message_to_user,
        background_tasks=background_tasks,
    )
