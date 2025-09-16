"""
Роутер для операций с инструментами.

Содержит endpoint'ы для:
- Получения списка инструментов
- Создания новых инструментов
"""

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err, Ok

from src.api.modules.quest.responses import create_tool_responses
from src.api.modules.quest.schemas.quest import (ItemWithImageRead,
                                             ItemWithImageRequestSchema)
from src.api.modules.quest.utils import exceptions_mapper
from src.core.authorization.dependencies import require_manage_tools
from src.core.quest.dto import ItemWithImageDTO
from src.core.quest.services import ItemService
from src.db.models import User

router = APIRouter()


@router.get("/", response_model=list[ItemWithImageRead])
@inject
async def get_points_tools(
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_tools)
) -> list[ItemWithImageRead]:
    """Получение списка всех инструментов."""
    return await item_service.get_items("tools")


@router.post(
    "/",
    response_model=ItemWithImageRead,
    status_code=status.HTTP_201_CREATED,
    responses=create_tool_responses,
)
@inject
async def create_point_tool(
    tool_data: ItemWithImageRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_tools)
) -> ItemWithImageRead:
    """Создание нового инструмента (только для администраторов)."""
    tool_dto = ItemWithImageDTO(
        name=tool_data.name,
        image=tool_data.image,
    )

    create_result = await item_service.create_item("tools", tool_dto)
    
    if isinstance(create_result, Err):
        await exceptions_mapper(create_result.err(), item_service)
    
    return create_result.ok() 