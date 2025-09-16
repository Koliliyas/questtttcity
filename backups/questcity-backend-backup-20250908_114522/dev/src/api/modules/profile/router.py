from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err

from api.modules.profile import responses as profile_resps
from api.modules.profile.exceptions import ProfileNotFoundHTTPError
from api.modules.profile.schemas import (ProfileUpdateAdminSchema,
                                         ProfileUpdateSchema)
from core.authentication.dependencies import get_user_with_role
from core.profile.dto import ProfileUpdateDTO
from core.profile.exceptions import ProfileNotFoundError
from core.profile.services import ProfileService
from core.repositories import S3Repository
from db.models.user import User

router = APIRouter(
    prefix="/profiles",
    tags=["Profiles"],
)


@router.patch(
    "/me",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=profile_resps.update_profile_responses,
)
@inject
async def update_me_profile(
    data: ProfileUpdateSchema,
    s3_repository: Injected[S3Repository],
    profile_service: Injected[ProfileService],
    user: User = Depends(get_user_with_role("user")),
):
    avatar_url = (
        await s3_repository.upload_file("avatars", data.image)
        if data.image is not None
        else None
    )
    profile_dto = ProfileUpdateDTO(
        avatar_url=avatar_url,
        instagram_username=data.instagram_username,
        credits=None,
    )

    result = await profile_service.update(
        profile_id=user.profile_id, profile_dto=profile_dto
    )

    if isinstance(result, Err):
        match result.err_value:
            case ProfileNotFoundError():
                raise ProfileNotFoundHTTPError


@router.patch(
    "/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=profile_resps.update_me_profile_responses,
)
@inject
async def update_me_profile(
    id: int,
    data: ProfileUpdateAdminSchema,
    s3_repository: Injected[S3Repository],
    profile_service: Injected[ProfileService],
    user: User = Depends(get_user_with_role("admin")),
):
    avatar_url = (
        await s3_repository.upload_file("avatars", data.image)
        if data.image is not None
        else None
    )
    profile_dto = ProfileUpdateDTO(
        avatar_url=avatar_url,
        instagram_username=data.instagram_username,
        credits=data.credits,
    )

    result = await profile_service.update(profile_id=id, profile_dto=profile_dto)

    if isinstance(result, Err):
        match result.err_value:
            case ProfileNotFoundError():
                raise ProfileNotFoundHTTPError
