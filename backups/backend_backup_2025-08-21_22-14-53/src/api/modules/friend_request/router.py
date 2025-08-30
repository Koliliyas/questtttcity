from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from fastapi_pagination import Page, Params
from result import Err

from src.api import exceptions as api_exc
from src.api.modules.friend import exceptions as f_api_exc
from src.api.modules.friend_request import exceptions as fr_api_exc
from src.api.modules.friend_request import responses as fr_res
from src.api.modules.friend_request import schemas as fr_sch
from src.core import exceptions as core_exc
from src.core.authentication.dependencies import get_user_with_role
from src.core.friend import exceptions as f_exc
from src.core.friend.dto import FriendCreateDTO
from src.core.friend.services import FriendService
from src.core.friend_request import exceptions as fr_core_exc
from src.core.friend_request.dto import (FriendRequestCreateDTO,
                                     FriendRequestUpdateDTO)
from src.core.friend_request.services import FriendRequestService
from src.core.user.repositories import UserRepository
from src.db.models.user import User

router = APIRouter()


@router.get("/sent/me", responses=fr_res.get_me_friend_requests_sent_responses)
@inject
async def get_me_friend_requests_sent(
    friend_request_service: Injected[FriendRequestService],
    params: Params = Depends(),
    user: User = Depends(get_user_with_role("user")),
) -> Page[fr_sch.FriendRequestSentReadSchema]:
    result = await friend_request_service.get_all_sent_for(id=user.id, params=params)

    return result.ok_value


@router.delete(
    "/sent/me/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=fr_res.delete_sent_me_friend_request_responses,
)
@inject
async def delete_sent_me_friend_request(
    id: int,
    friend_request_service: Injected[FriendRequestService],
    user: User = Depends(get_user_with_role("user")),
):
    result = await friend_request_service.delete(friend_request_id=id, user_id=user.id)

    if isinstance(result, Err):
        match result.err_value:
            case fr_core_exc.FriendRequestNotFoundError():
                raise fr_api_exc.FriendRequestNotFoundHTTPError()
            case core_exc.PermissionDeniedError():
                raise api_exc.PermissionDeniedHTTPError()


@router.get("/received/me", responses=fr_res.get_me_friend_requests_received_responses)
@inject
async def get_me_friend_requests_received(
    friend_request_service: Injected[FriendRequestService],
    params: Params = Depends(),
    user: User = Depends(get_user_with_role("user")),
) -> Page[fr_sch.FriendRequestReceivedReadSchema]:
    result = await friend_request_service.get_all_received_for(
        id=user.id, params=params
    )

    return result.ok_value


@router.patch(
    "/received/me/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=fr_res.update_me_friend_request_received_responses,
)
@inject
async def update_me_friend_request_received(
    id: int,
    friend_request_update_data: fr_sch.FriendRequestReceivedUpdateSchema,
    friend_request_service: Injected[FriendRequestService],
    friend_service: Injected[FriendService],
    user: User = Depends(get_user_with_role("user")),
) -> None:
    dto = FriendRequestUpdateDTO(status=friend_request_update_data.status)
    result = await friend_request_service.update(
        friend_request_id=id, user_id=user.id, dto=dto
    )

    if isinstance(result, Err):
        match result.err_value:
            case fr_core_exc.FriendRequestNotFoundError():
                raise fr_api_exc.FriendRequestNotFoundHTTPError()
            case core_exc.PermissionDeniedError():
                raise api_exc.PermissionDeniedHTTPError()
    if friend_request_update_data.status == "accepted":
        friend_request = result.ok_value
        dto = FriendCreateDTO(
            friend_id=friend_request.requester_id, me_id=friend_request.recipient_id
        )
        result = await friend_service.create(dto=dto)

        if isinstance(result, Err):
            match result.err_value:
                case f_exc.UserNotEligibleForFriendError():
                    raise f_api_exc.UserNotEligibleForFriendHTTPError()
                case f_exc.FriendshipAlreadyExistsError():
                    raise f_api_exc.FriendshipAlreadyExistsHTTPError()


@router.post(
    "/me",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=fr_res.create_me_friend_request_responses,
)
@inject
async def create_me_friend_request(
    friend_request_create_data: fr_sch.FriendRequestCreateSchema,
    friend_request_service: Injected[FriendRequestService],
    user_repository: Injected[UserRepository],
    user: User = Depends(get_user_with_role("user")),
) -> None:
    user_for_friend = await user_repository.get_by_email(
        friend_request_create_data.recipient_email
    )

    if user_for_friend is None:
        raise fr_api_exc.UserNotEligibleForFriendRequestHTTPError()

    friend_request_dto = FriendRequestCreateDTO(
        requester_id=user.id, recipient_id=user_for_friend.id
    )
    result = await friend_request_service.create(dto=friend_request_dto)

    if isinstance(result, Err):
        match result.err_value:
            case fr_core_exc.SelfFriendRequestError():
                raise fr_api_exc.SelfFriendRequestHTTPError()
            case fr_core_exc.FriendRequestAlreadyExistsError():
                raise fr_api_exc.FriendRequestAlreadyExistsHTTPError()
            case fr_core_exc.UserNotEligibleForFriendRequestError():
                raise fr_api_exc.UserNotEligibleForFriendRequestHTTPError()
