from uuid import UUID

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, Query, status
from fastapi_pagination import Page, Params
from result import Err

from api.modules.friend import exceptions as f_api_exc
from api.modules.friend import responses as f_res
from api.modules.friend_request import exceptions as fr_api_exc
from api.modules.user.schemas import UserReadSchema
from core.authentication.dependencies import get_user_with_role
from core.friend import exceptions as f_exc
from core.friend.services import FriendService
from core.friend_request import exceptions as fr_core_exc
from core.friend_request.dto import FriendRequestUpdateDTO
from core.friend_request.services import FriendRequestService
from db.models.user import User

router = APIRouter()


@router.get(
    "/me",
    status_code=status.HTTP_200_OK,
    responses=f_res.get_friends_for_user_responses,
)
@inject
async def get_friends_for_me(
    friend_service: Injected[FriendService],
    search: str | None = Query(
        None, description="Search friend by username and full_name."
    ),
    params: Params = Depends(),
    user: User = Depends(get_user_with_role("user")),
) -> Page[UserReadSchema]:
    result = await friend_service.get_all_for(
        id=user.id, search_query=search, params=params
    )
    return result.ok_value


@router.get(
    "/{id}",
    status_code=status.HTTP_200_OK,
    responses=f_res.get_friends_for_user_responses,
)
@inject
async def get_friends_for_user(
    id: UUID,
    friend_service: Injected[FriendService],
    search: str | None = Query(
        None, description="Search friend by username and full_name."
    ),
    params: Params = Depends(),
) -> Page[UserReadSchema]:
    result = await friend_service.get_all_for(id=id, search_query=search, params=params)
    return result.ok_value


@router.delete(
    "/me/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=f_res.delete_friend_me_responses,
)
@inject
async def delete_friend_me(
    id: UUID,
    friend_service: Injected[FriendService],
    friend_request_service: Injected[FriendRequestService],
    user: User = Depends(get_user_with_role("user")),
):
    result = await friend_service.delete(user_id=user.id, friend_id=id)

    if isinstance(result, Err):
        match result.err_value:
            case f_exc.FriendshipNotFoundError():
                raise f_api_exc.FriendshipNotFoundHTTPError()

    result = await friend_request_service.get_one_between(user1_id=user.id, user2_id=id)

    if isinstance(result, Err):
        match result.err_value:
            case fr_core_exc.FriendRequestNotFoundError():
                raise fr_api_exc.FriendRequestNotFoundHTTPError()

    dto = FriendRequestUpdateDTO(status="sended")

    friend_request = result.ok_value

    await friend_request_service.update(
        friend_request_id=friend_request.id,
        user_id=friend_request.recipient_id,
        dto=dto,
    )
