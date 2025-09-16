from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, Query
from fastapi_pagination import Page, Params
from result import Err

from src.api.modules.quest.exceptions import QuestNotFoundHTTPError
from src.api.modules.reviews.exceptions import (
    ReviewAlreadyExistsHTTPError, ReviewNotFoundHTTPError,
    ReviewResponseAlreadyExistsHTTPError)
from src.api.modules.reviews.schemas import (CreateReviewResponseSchema,
                                         CreateReviewSchema, ReadReviewSchema)
from src.core.authentication.dependencies import get_user_with_role
from src.core.authorization.dependencies import require_moderate_reviews
from src.core.quest.dto import BaseReviewDTO, BaseReviewResponseDTO
from src.core.quest.exceptions import (QuestNotFoundException, ReviewAlreadyExists,
                                   ReviewNotFound, ReviewResponseAlreadyExists)
from src.core.quest.services import ReviewService
from src.db.models.user import User

router = APIRouter(
    prefix="/reviews",
    tags=["Reviews"],
)


@router.post("")
@inject
async def create_review(
    review_data: CreateReviewSchema,
    review_service: Injected[ReviewService],
    user: User = Depends(get_user_with_role("user")),
):
    dto = BaseReviewDTO(
        text=review_data.text,
        rating=review_data.rating,
        user_id=user.id,
        quest_id=review_data.quest_id,
    )

    result = await review_service.create(dto=dto)

    if isinstance(result, Err):
        match result.err_value:
            case QuestNotFoundException():
                raise QuestNotFoundHTTPError()
            case ReviewAlreadyExists():
                raise ReviewAlreadyExistsHTTPError()


@router.get("")
@inject
async def get_reviews(
    review_service: Injected[ReviewService],
    quest_id: int = Query(),
    params: Params = Depends(),
    user: User = Depends(get_user_with_role("user")),
) -> Page[ReadReviewSchema]:
    return await review_service.get_all(quest_id=quest_id, params=params)


@router.post("/{id}/response")
@inject
async def create_response_for_review(
    id: int,
    data_response: CreateReviewResponseSchema,
    review_service: Injected[ReviewService],
    user: User = Depends(require_moderate_reviews),
):
    dto = BaseReviewResponseDTO(
        text=data_response.text,
        review_id=id,
        user_id=user.id,
    )

    result = await review_service.create_response(dto=dto)
    if isinstance(result, Err):
        match result.err_value:
            case ReviewNotFound():
                raise ReviewNotFoundHTTPError()
            case ReviewResponseAlreadyExists():
                raise ReviewResponseAlreadyExistsHTTPError()
