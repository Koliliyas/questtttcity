"""
Роутер для операций с транспортом.

Содержит endpoint'ы для:
- Получения списка транспорта
- Создания новых видов транспорта
"""

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err, Ok

from src.api.modules.quest.responses import create_vehicle_responses
from src.api.modules.quest.schemas.quest import (ItemReadSchema,
                                             ItemRequestSchema)
from src.api.modules.quest.utils import exceptions_mapper
from src.core.authorization.dependencies import require_manage_vehicles
from src.core.quest.dto import ItemCreateDTO
from src.core.quest.services import ItemService
from src.db.models import User

router = APIRouter()


@router.get("/", response_model=list[ItemReadSchema])
@inject
async def get_vehicles(
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_vehicles)
) -> list[ItemReadSchema]:
    """Получение списка всех видов транспорта."""
    return await item_service.get_items("vehicles")


@router.post(
    "/",
    response_model=ItemReadSchema,
    status_code=status.HTTP_201_CREATED,
    responses=create_vehicle_responses,
)
@inject
async def create_vehicle(
    vehicle_data: ItemRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_vehicles)
) -> ItemReadSchema:
    """Создание нового вида транспорта (только для администраторов)."""
    vehicle_dto = ItemCreateDTO(name=vehicle_data.name)

    create_result = await item_service.create_item("vehicles", vehicle_dto)
    
    if isinstance(create_result, Err):
        await exceptions_mapper(create_result.err(), item_service)
    
    return create_result.ok() 