"""
Роутер для управления точками квеста.

Содержит endpoint'ы для:
- Создания точек квеста
- Обновления точек квеста
- Удаления точек квеста
- Получения списка точек квеста
"""

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err, Ok

from src.api.modules.quest.schemas.point import PointCreateSchema, PointUpdateSchema
from src.core.authorization.dependencies import require_edit_quests
from src.core.quest.dto import PointCreateDTO, PointUpdateDTO
from src.core.quest.services import QuestService
from src.db.models import User

router = APIRouter()


@router.post("/{quest_id}/points")
@inject
async def create_quest_point(
    quest_id: int,
    point_data: PointCreateSchema,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Создание новой точки квеста."""
    try:
        # Создаем DTO для создания точки
        point_create_dto = PointCreateDTO(
            name_of_location=point_data.name_of_location,
            description=point_data.description,
            order=point_data.order,
            type_id=point_data.type_id,
            places=point_data.places,
            type_photo=point_data.type_photo,
            type_code=point_data.type_code,
            type_word=point_data.type_word,
            tool_id=point_data.tool_id,
            file=point_data.file,
            is_divide=point_data.is_divide,
            quest_id=quest_id
        )
        
        # Создаем точку
        create_result = await quest_service.create_quest_point(quest_id, point_create_dto)
        
        if isinstance(create_result, Err):
            return {"error": "Failed to create quest point", "details": str(create_result.err())}
        
        point = create_result.ok()
        
        return {
            "success": True,
            "message": "Quest point created successfully",
            "point_id": point.id,
            "point": {
                "id": point.id,
                "name_of_location": point.name_of_location,
                "description": point.description,
                "order": point.order
            }
        }
        
    except Exception as e:
        import traceback
        return {
            "error": f"Internal server error: {str(e)}",
            "traceback": traceback.format_exc()
        }


@router.put("/{quest_id}/points/{point_id}")
@inject
async def update_quest_point(
    quest_id: int,
    point_id: int,
    point_data: PointUpdateSchema,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Обновление существующей точки квеста."""
    try:
        # Проверяем существование точки
        point_result = await quest_service.get_quest_point_by_id(quest_id, point_id)
        
        if isinstance(point_result, Err):
            return {"error": "Quest point not found", "point_id": point_id}
        
        # Создаем DTO для обновления точки
        point_update_dto = PointUpdateDTO(
            id=point_id,
            quest_id=quest_id,
            name_of_location=point_data.name_of_location,
            description=point_data.description,
            order=point_data.order,
            type_id=point_data.type_id,
            type_photo=point_data.type_photo,
            type_code=point_data.type_code,
            type_word=point_data.type_word,
            tool_id=point_data.tool_id,
            file=point_data.file,
            is_divide=point_data.is_divide,
            places=point_data.places
        )
        
        # Обновляем точку
        update_result = await quest_service.update_quest_point(quest_id, point_id, point_update_dto)
        
        if isinstance(update_result, Err):
            return {"error": "Failed to update quest point", "details": str(update_result.err())}
        
        point = update_result.ok()
        
        return {
            "success": True,
            "message": "Quest point updated successfully",
            "point_id": point.id,
            "point": {
                "id": point.id,
                "name_of_location": point.name_of_location,
                "description": point.description,
                "order": point.order
            }
        }
        
    except Exception as e:
        import traceback
        return {
            "error": f"Internal server error: {str(e)}",
            "traceback": traceback.format_exc()
        }


@router.delete("/{quest_id}/points/{point_id}")
@inject
async def delete_quest_point(
    quest_id: int,
    point_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Удаление точки квеста."""
    try:
        # Проверяем существование точки
        point_result = await quest_service.get_quest_point_by_id(quest_id, point_id)
        
        if isinstance(point_result, Err):
            return {"error": "Quest point not found", "point_id": point_id}
        
        # Удаляем точку
        delete_result = await quest_service.delete_quest_point(quest_id, point_id)
        
        if isinstance(delete_result, Err):
            return {"error": "Failed to delete quest point", "details": str(delete_result.err())}
        
        return {
            "success": True,
            "message": f"Quest point {point_id} deleted successfully",
            "point_id": point_id
        }
        
    except Exception as e:
        import traceback
        return {
            "error": f"Internal server error: {str(e)}",
            "traceback": traceback.format_exc()
        }


@router.get("/{quest_id}/points")
@inject
async def get_quest_points(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Получение списка точек квеста."""
    try:
        points_result = await quest_service.get_quest_points_list(quest_id)
        
        if isinstance(points_result, Err):
            return {"error": "Failed to get quest points", "details": str(points_result.err())}
        
        points = points_result.ok()
        
        # Формируем список точек для админки
        admin_points = []
        for point in points:
            admin_points.append({
                "id": point.id,
                "name_of_location": point.name_of_location,
                "description": point.description,
                "order": point.order,
                "type_id": point.type_id,
                "quest_id": point.quest_id
            })
        
        return {
            "success": True,
            "points": admin_points,
            "total": len(admin_points)
        }
        
    except Exception as e:
        import traceback
        return {
            "error": f"Internal server error: {str(e)}",
            "traceback": traceback.format_exc()
        }




















