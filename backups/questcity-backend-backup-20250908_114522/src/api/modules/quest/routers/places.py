"""
Роутер для операций с местами.

Содержит endpoint'ы для:
- Получения списка мест
- Создания новых мест
"""

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err, Ok

from src.api.modules.quest.responses import create_place_responses
from src.api.modules.quest.schemas.quest import (ItemReadSchema,
                                             ItemRequestSchema)
from src.api.modules.quest.utils import exceptions_mapper
from src.core.authorization.dependencies import require_manage_places
from src.core.quest.dto import ItemCreateDTO
from src.core.quest.services import ItemService
from src.db.models import User

router = APIRouter()


@router.get("/", response_model=list[ItemReadSchema])
@inject
async def get_places(
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_places)
) -> list[ItemReadSchema]:
    """Получение списка всех мест."""
    return await item_service.get_items("place")


@router.post(
    "/",
    response_model=ItemReadSchema,
    status_code=status.HTTP_201_CREATED,
    responses=create_place_responses,
)
@inject
async def create_place(
    place_data: ItemRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_places)
) -> ItemReadSchema:
    """Создание нового места (только для администраторов)."""
    place_dto = ItemCreateDTO(title=place_data.title)

    create_result = await item_service.create_place(place_dto)
    
    if isinstance(create_result, Err):
        await exceptions_mapper(create_result.err(), item_service)
    
    return create_result.ok() 