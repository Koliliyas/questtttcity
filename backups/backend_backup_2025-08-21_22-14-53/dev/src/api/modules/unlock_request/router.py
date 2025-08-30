from typing import assert_never

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from fastapi_filter import FilterDepends
from fastapi_pagination import Page, Params
from result import Err

from api.exceptions import UserNotFoundHTTPError
from api.modules.unlock_request import exceptions as api_ur_exc
from api.modules.unlock_request import responses as ur_res
from api.modules.unlock_request.filters import UnlockRequestFilter
from api.modules.unlock_request.schemas import (UnlockRequestCreateSchema,
                                                UnlockRequestReadSchema,
                                                UnlockRequestUpdateSchema)
from core.authentication.dependencies import get_user_with_role
from core.unlock_request import exceptions as ur_exc
from core.unlock_request.dto import (UnlockRequestCreateDTO,
                                     UnlockRequestUpdateDTO)
from core.unlock_request.services import UnlockRequestService
from core.user.exceptions import UserNotFoundError
from db.models.user import User

router = APIRouter(
    prefix="/unlock_requests",
    tags=["Unlock requests"],
)


@router.get(
    "",
    response_model=Page[UnlockRequestReadSchema],
    responses=ur_res.get_unlock_requests_responses,
)
@inject
async def get_unlock_requests(
    unlock_request_service: Injected[UnlockRequestService],
    params: Params = Depends(),
    unlock_request_filter: UnlockRequestFilter = FilterDepends(UnlockRequestFilter),
    user: User = Depends(get_user_with_role("admin")),
) -> Page[UnlockRequestReadSchema]:
    result = await unlock_request_service.get_unlock_requests(
        filter=unlock_request_filter, pagination_params=params
    )
    return result.ok_value


@router.post(
    "",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=ur_res.create_unlock_request_responses,
)
@inject
async def create_unlock_request(
    unlock_request: UnlockRequestCreateSchema,
    unlock_request_service: Injected[UnlockRequestService],
):
    unlock_request_dto = UnlockRequestCreateDTO(
        email=unlock_request.email,
        reason=unlock_request.reason,
        message=unlock_request.message,
    )

    result = await unlock_request_service.create_unlock_request(
        unlock_request_dto=unlock_request_dto
    )

    if isinstance(result, Err):
        match result.err_value:
            case ur_exc.PendingUnlockRequestExistsError():
                raise api_ur_exc.PendingUnlockRequestExistsHTTPError()
            case ur_exc.ActiveUserError():
                raise api_ur_exc.ActiveUserHTTPError()
            case UserNotFoundError():
                raise UserNotFoundHTTPError()
            case _ as never:
                assert_never(never)


@router.get(
    "/{id}",
    response_model=UnlockRequestReadSchema,
    responses=ur_res.get_unlock_request_responses,
)
@inject
async def get_unlock_request(
    id: int,
    unlock_request_service: Injected[UnlockRequestService],
    user: User = Depends(get_user_with_role("admin")),
):
    result = await unlock_request_service.get_unlock_request(id=id)
    if isinstance(result, Err):
        match result.err_value:
            case ur_exc.UnlockRequestNotFoundError():
                raise api_ur_exc.UnlockRequestNotFoundHTTPError()
            case _ as never:
                assert_never(never)

    unlock_request = result.ok_value

    return unlock_request


@router.patch(
    "/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=ur_res.update_unlock_request_responses,
)
@inject
async def update_unlock_request(
    id: int,
    unlock_request_data: UnlockRequestUpdateSchema,
    unlock_request_service: Injected[UnlockRequestService],
    user: User = Depends(get_user_with_role("admin")),
):
    unlock_request_dto = UnlockRequestUpdateDTO(status=unlock_request_data.status)

    result = await unlock_request_service.update_unlock_request(
        id_=id, unlock_request_dto=unlock_request_dto
    )

    if isinstance(result, Err):
        match result.err_value:
            case ur_exc.UnlockRequestNotFoundError():
                raise api_ur_exc.UnlockRequestNotFoundHTTPError()
