"""
Роутер для операций с типами активности.

Содержит endpoint'ы для:
- Получения списка типов активности
- Создания новых типов активности
"""

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err, Ok

from src.api.modules.quest.responses import create_activity_responses
from src.api.modules.quest.schemas.quest import (ItemReadSchema,
                                             ItemRequestSchema)
from src.api.modules.quest.utils import exceptions_mapper
from src.core.authorization.dependencies import require_manage_activities
from src.core.quest.dto import ItemCreateDTO
from src.core.quest.services import ItemService
from src.db.models import User

router = APIRouter()


@router.get("/", response_model=list[ItemReadSchema])
@inject
async def get_point_types(
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_activities)
) -> list[ItemReadSchema]:
    """Получение списка всех типов активности."""
    return await item_service.get_items("activity")  # Исправлено: "types" -> "activity"


@router.post(
    "/",
    response_model=ItemReadSchema,
    status_code=status.HTTP_201_CREATED,
    responses=create_activity_responses,
)
@inject
async def create_point_type(
    activity_data: ItemRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_activities)
) -> ItemReadSchema:
    """Создание нового типа активности (только для администраторов)."""
    activity_dto = ItemCreateDTO(name=activity_data.name)

    create_result = await item_service.create_item("activity", activity_dto)  # Исправлено: "types" -> "activity"
    
    if isinstance(create_result, Err):
        await exceptions_mapper(create_result.err(), item_service)
    
    return create_result.ok() 