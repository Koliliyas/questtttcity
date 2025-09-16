from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err

from api.modules.favorite import responses as favorite_resps
from api.modules.favorite.exceptions import (FavoriteAlreadyExistsHTTPError,
                                             FavoriteNotFoundHTTPError)
from api.modules.favorite.schemas import (FavoriteCreateSchema,
                                          FavoritesReadSchema)
from api.modules.quest.exceptions import QuestNotFoundHTTPError
from core.authentication.dependencies import get_user_with_role
from core.favorite.dto import BaseFavoriteDTO
from core.favorite.exceptions import (FavoriteAlreadyExistsError,
                                      FavoriteNotFoundError)
from core.favorite.services import FavoriteService
from core.quest.exceptions import QuestNotFoundException
from db.models.user import User

router = APIRouter(
    prefix="/favorites",
    tags=["Favorites"],
)


@router.post(
    "", status_code=status.HTTP_200_OK, responses=favorite_resps.make_favorite_responses
)
@inject
async def make_favorite(
    data: FavoriteCreateSchema,
    favorite_service: Injected[FavoriteService],
    user: User = Depends(get_user_with_role("user")),
):
    dto = BaseFavoriteDTO(quest_id=data.quest_id, user_id=user.id)

    result = await favorite_service.create(dto=dto)

    if isinstance(result, Err):
        match result.err_value:
            case QuestNotFoundException():
                raise QuestNotFoundHTTPError()
            case FavoriteAlreadyExistsError():
                raise FavoriteAlreadyExistsHTTPError()


@router.get(
    "",
    status_code=status.HTTP_200_OK,
    response_model=FavoritesReadSchema,
    responses=favorite_resps.get_favorites_for_user_responses,
)
@inject
async def get_favorites_for_user(
    favorite_service: Injected[FavoriteService],
    user: User = Depends(get_user_with_role("user")),
):
    result = await favorite_service.get_all(user_id=user.id)
    return {"items": result.ok_value}


@router.delete(
    "",
    status_code=status.HTTP_200_OK,
    responses=favorite_resps.delete_from_favorites_responses,
)
@inject
async def delete_from_favorites(
    data: FavoriteCreateSchema,
    favorite_service: Injected[FavoriteService],
    user: User = Depends(get_user_with_role("user")),
):
    dto = BaseFavoriteDTO(user_id=user.id, quest_id=data.quest_id)
    result = await favorite_service.delete(dto=dto)

    if isinstance(result, Err):
        match result.err_value:
            case FavoriteNotFoundError():
                raise FavoriteNotFoundHTTPError()
