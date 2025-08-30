"""
Роутер для операций с категориями квестов.

Содержит endpoint'ы для:
- Получения списка категорий
- Создания новых категорий
- Обновления существующих категорий
"""

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err, Ok

from src.api.modules.quest.responses import (create_category_responses,
                                         update_category_responses)
from src.api.modules.quest.schemas.quest import (ItemWithImageRead,
                                             ItemWithImageRequestSchema,
                                             ItemWithImageUpdateSchema)
from src.api.modules.quest.utils import exceptions_mapper
from src.core.authorization.dependencies import require_manage_categories, require_view_quests
from src.core.quest.dto import ItemWithImageDTO
from src.core.quest.services import ItemService
from src.db.models import User

router = APIRouter()


@router.get("/", response_model=list[ItemWithImageRead])
@inject
async def get_categories(
    item_service: Injected[ItemService],
    user: User = Depends(require_view_quests)
) -> list[ItemWithImageRead]:
    """Получение списка всех категорий."""
    return await item_service.get_items("categories")


@router.post(
    "/",
    response_model=ItemWithImageRead,
    status_code=status.HTTP_201_CREATED,
    responses=create_category_responses,
)
@inject
async def create_category(
    category_data: ItemWithImageRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_categories)
) -> ItemWithImageRead:
    """Создание новой категории (только для администраторов)."""
    category_dto = ItemWithImageDTO(
        name=category_data.name,
        image=category_data.image,
    )

    create_result = await item_service.create_item("categories", category_dto)
    
    if isinstance(create_result, Err):
        await exceptions_mapper(create_result.err(), item_service)
    
    return create_result.ok()


@router.patch(
    "/{category_id}",
    response_model=ItemWithImageRead,
    responses=update_category_responses,
)
@inject
async def update_category(
    category_id: int,
    category_data: ItemWithImageUpdateSchema,
    item_service: Injected[ItemService],
    user: User = Depends(require_manage_categories)
) -> ItemWithImageRead:
    """Обновление категории (только для администраторов)."""
    update_result = await item_service.update_item(
        "categories",
        category_data,
        category_id
    )
    
    if isinstance(update_result, Err):
        await exceptions_mapper(update_result.err(), item_service)
    
    return update_result.ok() 