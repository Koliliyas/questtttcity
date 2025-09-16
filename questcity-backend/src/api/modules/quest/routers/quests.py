"""
Роутер для основных операций с квестами.

Содержит endpoint'ы для:
- Получения списка квестов
- Получения детальной информации о квесте
- Получения текущего квеста пользователя
- Создания и обновления квестов
"""

from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status, Request
from result import Err, Ok

from src.api.modules.quest.responses import (create_quest_responses,
                                         get_all_quests_responses,
                                         get_quest_responses,
                                         update_quest_responses)
from src.api.modules.quest.schemas.point import (FileReadSettings,
                                             PointReadForCurrentQuestSchema,
                                             PointReadSchema, PointType)
from src.api.modules.quest.schemas.quest import (Credits, CurrentQuestSchema,
                                             MainPreferences, MerchReadSchema,
                                             PriceSettings, QuestAsItem,
                                             QuestCreteSchema, QuestReadSchema,
                                             QuestUpdateRequestSchema, PlaceSettingsRead, PlaceModelRead, QuestUpdateResponse, QuestEditSchema)
from src.api.modules.quest.utils import exceptions_mapper
from src.core.authorization.dependencies import require_edit_quests, require_view_quests, require_create_quests
from src.core.merch.dto import MerchCreateDTO, MerchUpdateDTO
from src.core.merch.service import MerchService
from src.core.quest.dto import (PlaceCreateDTO, PlaceUpdateDTO, PointCreateDTO,
                            PointUpdateDTO, QuestCreateDTO, QuestUpdateDTO)
from src.core.merch.dto import MerchCreateDTO
from src.core.quest.enums.quest import Level, Milage, GroupType, Timeframe  # Исправленный импорт
from src.api.modules.quest.schemas.quest import MainPreferences
from src.core.quest.services import QuestService
from src.db.models import User
from src.api.modules.quest.schemas.quest import QuestParameterModel

router = APIRouter()


@router.get("/working/{quest_id}")
@inject
async def get_quest_working(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_view_quests)
):
    """Рабочий эндпоинт детальной информации о квесте (без сложной схемы)."""
    try:
        quest_result = await quest_service.get_quest_by_id(quest_id)
        
        if isinstance(quest_result, Err):
            return {"error": "Quest not found", "quest_id": quest_id}
        
        quest = quest_result.ok()
        
        # Получаем все данные
        merch_list = await quest_service.get_merch_list_by_quest_id(quest_id)
        preferences = await quest_service.get_preferences_by_quest_id(quest_id)
        points = await quest_service.get_quest_points_list(quest_id)
        places = await quest_service.get_places_by_quest_id(quest_id)
        place_settings = await quest_service.get_place_settings_by_quest_id(quest_id)
        
        # Безопасно получаем Enum значения
        try:
            level_value = quest.level.value if quest.level else "Easy"
        except:
            level_value = "Easy"
        
        try:
            timeframe_value = quest.timeframe.value if quest.timeframe else "1-2 hours"
        except:
            timeframe_value = "1-2 hours"
        
        try:
            group_value = quest.group.value if quest.group else "Solo"
        except:
            group_value = "Solo"
        
        # Возвращаем данные в формате близком к ожидаемому QuestReadSchema
        return {
            "id": quest.id,
            "title": quest.name or "Без названия",
            "short_description": quest.description or "Описание не указано",
            "full_description": quest.description or "Описание не указано",
            "image_url": quest.image or "default.jpg",
            "category_id": quest.category_id,
            "category_title": quest.category.name if quest.category else None,  # Используем загруженную категорию
            "category_image_url": quest.category.image if quest.category else None,  # Используем загруженную категорию
            "difficulty": level_value,
            "price": quest.pay_extra or 0,
            "credits": {
                "cost": quest.cost if quest.cost is not None else 0,
                "reward": quest.reward if quest.reward is not None else 0,
            },
            "mentor_preference": quest.mentor_preference,  # Добавляем mentor_preference
            "duration": timeframe_value,
            "player_limit": 0,
            "age_limit": 0,
            "is_for_adv_users": False,
            "type": group_value,
            "merch_list": merch_list,
            "main_preferences": {
                "types": [item.get("id", 0) for item in preferences],
                "places": [item.get("id", 0) for item in places],
                "vehicles": [quest.vehicle_id] if quest.vehicle_id else [],
                "tools": [],
            },
            "points": points,
            "place_settings": {
                "type": place_settings.type.value,
                "settings": {
                    "id": place_settings.place.id,
                    "title": place_settings.place.title,
                } if place_settings.place else None,
            },
            "price_settings": {
                "type": "subscription" if quest.is_subscription else "default",
                "is_subscription": quest.is_subscription,
                "pay_extra": quest.pay_extra or 0,
            }
        }
        
    except Exception as e:
        import traceback
        return {
            "error": str(e),
            "traceback": traceback.format_exc(),
            "quest_id": quest_id
        }



@router.get("/", response_model=list[QuestAsItem], responses=get_all_quests_responses)
@inject
async def get_all_quests(
    quest_service: Injected[QuestService], user: User = Depends(require_view_quests)
) -> list[QuestAsItem]:
    """Получение списка всех квестов."""
    quests = await quest_service.get_all_quests()
    return quests


@router.get(
    "/{quest_id}",
    response_model=QuestReadSchema,
    responses=get_quest_responses,
)
@inject
async def get_quest(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_view_quests)
) -> QuestReadSchema:
    """Получение детальной информации о квесте."""
    quest_result = await quest_service.get_quest_by_id(quest_id)

    if isinstance(quest_result, Err):
        raise await exceptions_mapper(quest_result.err())
    
    quest = quest_result.ok()
    merch_list = await quest_service.get_merch_list_by_quest_id(quest_id)
    preferences = await quest_service.get_preferences_by_quest_id(quest_id)
    points = await quest_service.get_quest_points_list(quest_id)
    places = await quest_service.get_places_by_quest_id(quest_id)
    place_settings = await quest_service.get_place_settings_by_quest_id(quest_id)

    # Безопасно получаем значения Enum полей как строки
    level_value = str(quest.level.value) if quest.level else "Easy"
    timeframe_value = str(quest.timeframe.value) if quest.timeframe else "1-2 hours"
    group_value = str(quest.group.value) if quest.group else "Solo"

    return QuestReadSchema(
        id=quest.id,
        title=quest.name or "Без названия",
        short_description=quest.description or "Описание не указано",
        full_description=quest.description or "Описание не указано",
        image_url=quest.image or "default.jpg",
        category_id=quest.category_id,
        category_title=quest.category.name if quest.category else None,  # Используем загруженную категорию
        category_image_url=quest.category.image if quest.category else None,  # Используем загруженную категорию  
        difficulty=level_value,
        price=float(quest.pay_extra or 0),
        duration=timeframe_value,  # строка, не число
        player_limit=0,  # Поле отсутствует в модели
        age_limit=0,  # Поле отсутствует в модели
        is_for_adv_users=False,  # Поле отсутствует в модели
        type=group_value,  # строка, не число
        credits=Credits(
            cost=quest.cost if quest.cost is not None else 0,
            reward=quest.reward if quest.reward is not None else 0,
        ),
        mentor_preference=quest.mentor_preference,  # Добавляем mentor_preference
        merch_list=merch_list,
        main_preferences=MainPreferences(
            category_id=quest.category_id or 1,
            vehicle_id=quest.vehicle_id or 1,
            place_id=quest.place_id or 1,
            group=GroupType.ALONE,  # Дефолтное значение
            level=Level.EASY,  # Дефолтное значение
            mileage=Milage.UP_TO_TEN,  # Дефолтное значение
        ),
        points=points,
        place_settings=PlaceSettingsRead(
            type=place_settings.type.value,
            settings=PlaceModelRead(
                id=place_settings.place.id,
                title=place_settings.place.title,
            ) if place_settings.place else None,
        ),
        price_settings=PriceSettings(
            type="subscription" if quest.is_subscription else "default",
            is_subscription=quest.is_subscription,
            pay_extra=float(quest.pay_extra or 0),
        ),
    )


@router.get(
    "/me/{user_id}",
    response_model=CurrentQuestSchema | None,
)
@inject
async def get_current_quest(
    user_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_view_quests)
) -> CurrentQuestSchema | None:
    """Получение текущего квеста пользователя."""
    current_quest_result = await quest_service.get_current_quest_by_user_id(user_id)

    if isinstance(current_quest_result, Err):
        return None
    
    quest = current_quest_result.ok()
    progress = await quest_service.get_quest_progress_by_user_id(user_id, quest.id)
    points = await quest_service.get_quest_points_for_current_quest(quest.id)
    
    return CurrentQuestSchema(
        id=quest.id,
        title=quest.title,
        short_description=quest.short_description,
        image_url=quest.image_url,
        category_id=quest.category_id,
        category_title=quest.category.title if quest.category else None,
        category_image_url=quest.category.image_url if quest.category else None,
        difficulty=quest.difficulty,
        price=quest.price,
        duration=quest.duration,
        player_limit=quest.player_limit,
        age_limit=quest.age_limit,
        is_for_adv_users=quest.is_for_adv_users,
        type=quest.type,
        progress=progress,
        points=points,
    )


@router.patch(
    "/{quest_id}",
    response_model=dict,
    responses=update_quest_responses,
)
@inject
async def update_quest(
    quest_id: int,
    quest_data: QuestUpdateRequestSchema,
    quest_service: Injected[QuestService],
    merch_service: Injected[MerchService],
    user: User = Depends(require_edit_quests)
) -> QuestReadSchema:
    """Обновление квеста (только для администраторов)."""
    
    # Получаем существующий квест для обновления
    quest_obj = await quest_service.get_quest_by_id(quest_id)
    if isinstance(quest_obj, Err):
        raise await exceptions_mapper(quest_obj.err())
    
    existing_quest = quest_obj.ok()
    
    # Отладочная информация
    print(f"DEBUG: quest_data.credits = {quest_data.credits}")
    print(f"DEBUG: quest_data.main_preferences = {quest_data.main_preferences}")
    if quest_data.credits:
        print(f"DEBUG: credits.auto = {quest_data.credits.auto}")
        print(f"DEBUG: credits.cost = {quest_data.credits.cost}")
        print(f"DEBUG: credits.reward = {quest_data.credits.reward}")
    if quest_data.main_preferences:
        print(f"DEBUG: main_preferences.category_id = {quest_data.main_preferences.category_id}")
        print(f"DEBUG: main_preferences.group = {quest_data.main_preferences.group}")
        print(f"DEBUG: main_preferences.timeframe = {quest_data.main_preferences.timeframe}")
    
    # Создаем DTO для обновления с правильной обработкой main_preferences
    quest_update_dto = QuestUpdateDTO(
        id=quest_id,
        name=quest_data.name or existing_quest.name,
        description=quest_data.description or existing_quest.description,
        image=quest_data.image or existing_quest.image,
        mentor_preference=quest_data.mentor_preference or existing_quest.mentor_preference,
        # Используем данные из credits если они есть, иначе существующие значения
        auto_accrual=quest_data.credits.auto if quest_data.credits else existing_quest.auto_accrual,
        cost=quest_data.credits.cost if quest_data.credits else existing_quest.cost,
        reward=quest_data.credits.reward if quest_data.credits else existing_quest.reward,
        # Используем данные из main_preferences если они есть, иначе существующие значения
        is_subscription=quest_data.main_preferences.price_settings.is_subscription if quest_data.main_preferences and hasattr(quest_data.main_preferences, 'price_settings') and quest_data.main_preferences.price_settings else existing_quest.is_subscription,
        pay_extra=quest_data.main_preferences.price_settings.amount if quest_data.main_preferences and hasattr(quest_data.main_preferences, 'price_settings') and quest_data.main_preferences.price_settings else existing_quest.pay_extra,
        level=quest_data.main_preferences.level if quest_data.main_preferences else existing_quest.level,
        milage=quest_data.main_preferences.mileage if quest_data.main_preferences else existing_quest.milage,
        category_id=quest_data.main_preferences.category_id if quest_data.main_preferences else existing_quest.category_id,
        vehicle_id=quest_data.main_preferences.vehicle_id if quest_data.main_preferences else existing_quest.vehicle_id,
        place_id=quest_data.main_preferences.place_id if quest_data.main_preferences else existing_quest.place_id,
        group=quest_data.main_preferences.group if quest_data.main_preferences else existing_quest.group,
        timeframe=quest_data.main_preferences.timeframe if quest_data.main_preferences else existing_quest.timeframe,
    )

    # Подготавливаем DTO для мерча
    merch_dtos = []
    for merch_item in quest_data.merch:
        merch_update_dto = MerchUpdateDTO(
            id=merch_item.id,
            description=merch_item.description,
            price=merch_item.price,
            image=merch_item.image,
        )
        merch_dtos.append(merch_update_dto)

    # Подготавливаем DTO для точек
    points_dtos = []
    for point_data in quest_data.points:
        point_update_dto = PointUpdateDTO(
            id=point_data.id,
            quest_id=quest_id,
            name_of_location=point_data.name_of_location,
            description=point_data.description,
            order=point_data.order,
            type_id=point_data.type_id,
            tool_id=point_data.tool_id,
            file=point_data.file,
            is_divide=point_data.is_divide,
            places=[
                PlaceUpdateDTO(
                    id=place.id,
                    point_id=None,  # Будет установлен позже в сервисе
                    longitude=place.longitude,
                    latitude=place.latitude,
                    detections_radius=place.detections_radius,
                    height=place.height,
                    interaction_inaccuracy=place.interaction_inaccuracy,
                    part=place.part,
                    random_occurrence=place.random_occurrence,
                )
                for place in point_data.places
            ],
        )
        points_dtos.append(point_update_dto)

    # Вызываем update_quest с правильными параметрами
    quest_update_result = await quest_service.update_quest(
        quest_dto=quest_update_dto,
        merchs_dtos=merch_dtos,
        points_dtos=points_dtos,
    )

    if isinstance(quest_update_result, Err):
        raise await exceptions_mapper(quest_update_result.err())

    # Возвращаем простой словарь вместо SQLAlchemy модели
    quest_obj = quest_update_result.ok()
    return {
        "id": quest_obj.id,
        "name": quest_obj.name,
        "description": quest_obj.description,
        "image": quest_obj.image,
        "mentor_preference": quest_obj.mentor_preference,
        "auto_accrual": quest_obj.auto_accrual,
        "cost": quest_obj.cost,
        "reward": quest_obj.reward,
        "category_id": quest_obj.category_id,
        "group": quest_obj.group.value if quest_obj.group else None,
        "vehicle_id": quest_obj.vehicle_id,
        "is_subscription": quest_obj.is_subscription,
        "pay_extra": quest_obj.pay_extra,
        "timeframe": quest_obj.timeframe.value if quest_obj.timeframe else None,
        "level": quest_obj.level.value if quest_obj.level else None,
        "milage": quest_obj.milage.value if quest_obj.milage else None,
        "place_id": quest_obj.place_id,
        "created_at": quest_obj.created_at,
        "updated_at": quest_obj.updated_at,
        "message": "Quest updated successfully"
    }


@router.post(
    "/",
    response_model=QuestReadSchema,
    status_code=status.HTTP_201_CREATED,
    responses=create_quest_responses,
)
@inject
async def create_quest(
    quest_data: QuestCreteSchema,
    quest_service: Injected[QuestService],
    merch_service: Injected[MerchService],
    user: User = Depends(require_edit_quests)
) -> QuestReadSchema:
    """Создание нового квеста (только для администраторов)."""
    
    # Упрощенное создание DTO с дефолтными значениями
    quest_create_dto = QuestCreateDTO(
        name=quest_data.name,
        description=quest_data.description,
        image=quest_data.image,
        mentor_preference=quest_data.mentor_preference or "",
        auto_accrual=False,
        cost=quest_data.credits.cost if quest_data.credits else 0,
        reward=quest_data.credits.reward if quest_data.credits else 0,
        is_subscription=False,
        pay_extra=0,
        level=Level.EASY,
        milage=Milage.UP_TO_TEN,
        category_id=1,  # Дефолтная категория
        vehicle_id=1,   # Дефолтное ТС
        place_id=1,     # Дефолтное место
        group=GroupType.TWO,
        timeframe=Timeframe.ONE_HOUR,
    )

    # Подготавливаем DTO для мерча (пустой список по умолчанию)
    merch_dtos = []
    for merch_item in quest_data.merch:
        merch_create_dto = MerchCreateDTO(
            description=merch_item.description,
            price=merch_item.price,
            image=merch_item.image,
        )
        merch_dtos.append(merch_create_dto)

    # Подготавливаем DTO для точек (пустой список по умолчанию)
    points_dtos = []
    for point_data in quest_data.points:
        point_create_dto = PointCreateDTO(
            name_of_location=point_data.name_of_location,
            description=point_data.description,
            order=point_data.order,
            type_id=point_data.type_id,
            places=[
                PlaceCreateDTO(
                    longitude=place.longitude,
                    latitude=place.latitude,
                    detections_radius=place.detections_radius,
                    height=place.height,
                    interaction_inaccuracy=place.interaction_inaccuracy,
                    part=place.part,
                    random_occurrence=place.random_occurrence,
                )
                for place in point_data.places
            ],
            tool_id=point_data.tool_id,
            file=point_data.file,
            is_divide=point_data.is_divide,
        )
        points_dtos.append(point_create_dto)

    # Вызываем create_quest с правильными параметрами
    quest_create_result = await quest_service.create_quest(
        quest_dto=quest_create_dto,
        merch_dtos=merch_dtos,
        points_dtos=points_dtos,
    )

    if isinstance(quest_create_result, Err):
        raise await exceptions_mapper(quest_create_result.err())
    
    quest = quest_create_result.ok()

    # Возвращаем созданный квест через стандартный endpoint
    return await get_quest(quest.id)


@router.get("/diagnostic-router")
async def diagnostic_router():
    """Диагностический эндпоинт для проверки состояния роутера квестов."""
    return {
        "status": "Router is working",
        "endpoints": [
            "GET /working/{quest_id}",
            "GET /",
            "GET /{quest_id}",
            "GET /me/{user_id}",
            "POST /",
            "PATCH /{quest_id}",
            "DELETE /{quest_id}",
            "GET /diagnostic-schema/{quest_id}",
            "GET /get-quest/{quest_id}",
        ],
        "timestamp": "2025-08-11T14:15:00Z"
    }

@router.post("/test-create")
async def test_create_quest():
    """Тестовый эндпоинт для проверки POST запросов без сложных зависимостей."""
    return {
        "status": "POST endpoint is working",
        "message": "Test endpoint for quest creation",
        "timestamp": "2025-08-11T14:15:00Z"
    }

@router.post("/simple-create")
async def simple_create_quest():
    """Упрощенный эндпоинт для проверки создания квеста без сложных зависимостей."""
    return {
        "status": "Simple create endpoint is working",
        "message": "This endpoint should work without complex dependencies",
        "timestamp": "2025-08-11T14:15:00Z"
    }

@router.post("/debug-create")
async def debug_create_quest():
    """Отладочный эндпоинт для проверки POST запросов без авторизации."""
    return {
        "status": "Debug create endpoint is working",
        "message": "This endpoint works without authorization",
        "timestamp": "2025-08-11T14:15:00Z"
    }

@router.get("/diagnostic-schema/{quest_id}")
@inject
async def get_quest_diagnostic_schema(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_view_quests)
):
    """Диагностический эндпоинт для тестирования QuestReadSchema валидации."""
    try:
        quest_result = await quest_service.get_quest_by_id(quest_id)
        
        if isinstance(quest_result, Err):
            return {"error": "Quest not found", "quest_id": quest_id}
        
        quest = quest_result.ok()
        
        # Получаем все данные
        merch_list = await quest_service.get_merch_list_by_quest_id(quest_id)
        preferences = await quest_service.get_preferences_by_quest_id(quest_id)
        points = await quest_service.get_quest_points_list(quest_id)
        places = await quest_service.get_places_by_quest_id(quest_id)
        place_settings = await quest_service.get_place_settings_by_quest_id(quest_id)
        
        # Безопасно получаем Enum значения как строки
        level_value = str(quest.level.value) if quest.level else "Easy"
        timeframe_value = str(quest.timeframe.value) if quest.timeframe else "1-2 hours"
        group_value = str(quest.group.value) if quest.group else "Solo"
        
        # Подготавливаем данные для схемы
        schema_data = {
            "id": quest.id,
            "title": quest.name or "Без названия",
            "short_description": quest.description or "Описание не указано",
            "full_description": quest.description or "Описание не указано",
            "image_url": quest.image or "default.jpg",
            "category_id": quest.category_id,
            "category_title": None,
            "category_image_url": None,
            "difficulty": level_value,
            "price": float(quest.pay_extra or 0),
            "duration": timeframe_value,  # строка, не число
            "player_limit": 0,
            "age_limit": 0,
            "is_for_adv_users": False,
            "type": group_value,  # строка, не число
            "credits": {
                "cost": quest.cost if quest.cost is not None else 0,
                "reward": quest.reward if quest.reward is not None else 0,
            },
            "merch_list": merch_list,
            "main_preferences": {
                "types": [item.get("id", 0) for item in preferences],
                "places": [item.get("id", 0) for item in places],
                "vehicles": [quest.vehicle_id] if quest.vehicle_id else [],
                "tools": [],
            },
            "points": points,
            "place_settings": {
                "type": place_settings.type.value,
                "settings": {
                    "id": place_settings.place.id,
                    "title": place_settings.place.title,
                } if place_settings.place else None,
            },
            "price_settings": {
                "type": "subscription" if quest.is_subscription else "default",
                "is_subscription": quest.is_subscription,
                "pay_extra": float(quest.pay_extra or 0),
            }
        }
        
        # Пробуем создать схему
        try:
            schema_instance = QuestReadSchema(**schema_data)
            return {
                "success": True,
                "message": "Schema validation passed!",
                "data": schema_instance.model_dump()
            }
        except Exception as schema_error:
            return {
                "success": False,
                "schema_error": str(schema_error),
                "raw_data": schema_data
            }
        
    except Exception as e:
        import traceback
        return {
            "error": str(e),
            "traceback": traceback.format_exc(),
            "quest_id": quest_id
        }


# @router.delete("/{quest_id}")
# @inject
# async def delete_quest(
#     quest_id: int,
#     quest_service: Injected[QuestService],
#     user: User = Depends(require_edit_quests)
# ):
#     """Удаление квеста по ID."""
#     try:
#         # Проверяем существование квеста
#         quest_result = await quest_service.get_quest_by_id(quest_id)
#         
#         if isinstance(quest_result, Err):
#             return {"error": "Quest not found", "quest_id": quest_id}
#         
#         # Удаляем квест
#         delete_result = await quest_service.delete_quest(quest_id)
#         
#         if isinstance(delete_result, Err):
#             return {"error": "Failed to delete quest", "quest_id": quest_id, "details": str(delete_result.err())}
#         
#         return {"success": True, "message": f"Quest {quest_id} deleted successfully", "quest_id": quest_id}
#         
#     except Exception as e:
#         import traceback
#         return {
#             "error": str(e),
#             "traceback": traceback.format_exc(),
#             "quest_id": quest_id
#         } 


@router.get("/user/{quest_id}")
@inject
async def get_user_quest_detail(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_view_quests)
):
    """Получение детальной информации о квесте для пользователей."""
    try:
        quest_result = await quest_service.get_quest_by_id(quest_id)
        
        if isinstance(quest_result, Err):
            return {"error": "Quest not found", "quest_id": quest_id}
        
        quest = quest_result.ok()
        
        # Получаем связанные данные
        merch_list = await quest_service.get_merch_list_by_quest_id(quest_id)
        preferences = await quest_service.get_preferences_by_quest_id(quest_id)
        points = await quest_service.get_quest_points_list(quest_id)
        places = await quest_service.get_places_by_quest_id(quest_id)
        place_settings = await quest_service.get_place_settings_by_quest_id(quest_id)
        
        # Получаем отзывы (пока пустой список, можно добавить позже)
        reviews = []
        
        # Безопасно получаем Enum значения
        try:
            level_value = quest.level.value if quest.level else "beginner"
        except:
            level_value = "beginner"
        
        try:
            timeframe_value = quest.timeframe.value if quest.timeframe else "halfDay"
        except:
            timeframe_value = "halfDay"
        
        try:
            group_value = quest.group.value if quest.group else 1
        except:
            group_value = 1
        
        try:
            mileage_value = quest.milage.value if quest.milage else "local"
        except:
            mileage_value = "local"
        
        # Возвращаем данные в формате, совместимом с фронтендом
        return {
            "id": quest.id,
            "name": quest.name or "Без названия",
            "description": quest.description or "Описание не указано",
            "image": quest.image or "default.jpg",
            "rating": float(quest.rating) if hasattr(quest, 'rating') and quest.rating else 0.0,
            "merch": merch_list,
            "credits": {
                "auto": quest.auto_accrual or False,
                "cost": quest.cost if quest.cost is not None else 0,
                "reward": quest.reward if quest.reward is not None else 0,
            },
            "mentor_preference": quest.mentor_preference or "",
            "mainPreferences": {
                "categoryId": quest.category_id,
                "group": group_value,
                "vehicleId": quest.vehicle_id,
                "price": {
                    "isSubscription": quest.is_subscription or False,
                    "amount": quest.pay_extra or 0,
                },
                "timeframe": timeframe_value,
                "level": level_value,
                "mileage": mileage_value,
                "placeId": quest.place_id,
            },
            "points": points,
            "reviews": reviews
        }
        
    except Exception as e:
        return {"error": f"Internal server error: {str(e)}", "quest_id": quest_id}

@router.get("/get-quest/{quest_id}")
@inject
async def get_quest_simple(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_view_quests)
):
    """Простой эндпоинт для получения деталей квеста (совместимость с фронтендом)."""
    try:
        quest_result = await quest_service.get_quest_by_id(quest_id)
        
        if isinstance(quest_result, Err):
            return {"error": "Quest not found", "quest_id": quest_id}
        
        quest = quest_result.ok()
        
        # Получаем связанные данные
        merch_list = await quest_service.get_merch_list_by_quest_id(quest_id)
        preferences = await quest_service.get_preferences_by_quest_id(quest_id)
        points = await quest_service.get_quest_points_list(quest_id)
        places = await quest_service.get_places_by_quest_id(quest_id)
        place_settings = await quest_service.get_place_settings_by_quest_id(quest_id)
        
        # Безопасно получаем Enum значения
        try:
            level_value = quest.level.value if quest.level else "beginner"
        except:
            level_value = "beginner"
        
        try:
            timeframe_value = quest.timeframe.value if quest.timeframe else "halfDay"
        except:
            timeframe_value = "halfDay"
        
        try:
            group_value = quest.group.value if quest.group else 1
        except:
            group_value = 1
        
        try:
            mileage_value = quest.milage.value if quest.milage else "local"
        except:
            mileage_value = "local"
        
        # Возвращаем данные в формате, совместимом с фронтендом
        return {
            "id": quest.id,
            "name": quest.name or "Без названия",
            "image": quest.image or "default.jpg",
            "merch": merch_list,
            "credits": {
                "auto": quest.auto_accrual or False,
                "cost": quest.cost if quest.cost is not None else 0,
                "reward": quest.reward if quest.reward is not None else 0,
            },
            "mentor_preference": quest.mentor_preference,  # Добавляем mentor_preference
            "mainPreferences": {
                "categoryId": quest.category_id,
                "group": group_value,
                "vehicleId": quest.vehicle_id,
                "price": {
                    "isSubscription": quest.is_subscription or False,
                    "amount": quest.pay_extra or 0,
                },
                "timeframe": timeframe_value,
                "level": level_value,
                "mileage": mileage_value,
                "placeId": quest.place_id,
            },
            "points": points,
            "reviews": []
        }
        
    except Exception as e:
        return {"error": f"Internal server error: {str(e)}", "quest_id": quest_id} 

@router.post("/create")
@inject
async def create_quest(
    quest_data: QuestCreteSchema,
    quest_service: Injected[QuestService],
    user: User = Depends(require_create_quests)
):
    """Создание нового квеста."""
    try:
        # Создаем DTO для создания квеста
        quest_create_dto = QuestCreateDTO(
            name=quest_data.name,
            description=quest_data.description,
            image=quest_data.image,
            mentor_preference=quest_data.mentor_preference or "",
            auto_accrual=quest_data.credits.auto,
            cost=quest_data.credits.cost,
            reward=quest_data.credits.reward,
            is_subscription=False,  # Пока не реализовано в схеме
            pay_extra=0,  # Пока не реализовано в схеме
            level=quest_data.main_preferences.level,
            milage=quest_data.main_preferences.mileage,
            category_id=quest_data.main_preferences.category_id,
            vehicle_id=quest_data.main_preferences.vehicle_id,
            place_id=quest_data.main_preferences.place_id,
            group=quest_data.main_preferences.group,
            timeframe=quest_data.main_preferences.timeframe
        )
        
        # Создаем квест
        create_result = await quest_service.create_quest(quest_create_dto)
        
        if isinstance(create_result, Err):
            return {"error": "Failed to create quest", "details": str(create_result.err())}
        
        quest = create_result.ok()
        
        return {
            "success": True,
            "message": "Quest created successfully",
            "quest_id": quest.id,
            "quest": {
                "id": quest.id,
                "name": quest.name,
                "description": quest.description,
                "image": quest.image
            }
        }
        
    except Exception as e:
        import traceback
        return {
            "error": f"Internal server error: {str(e)}",
            "traceback": traceback.format_exc()
        }


@router.put("/update/{quest_id}")
@inject
async def update_quest(
    quest_id: int,
    quest_data: QuestUpdateRequestSchema,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Обновление существующего квеста."""
    try:
        # Проверяем существование квеста
        quest_result = await quest_service.get_quest_by_id(quest_id)
        
        if isinstance(quest_result, Err):
            return {"error": "Quest not found", "quest_id": quest_id}
        
        # Создаем DTO для обновления квеста
        quest_update_dto = QuestUpdateDTO(
            id=quest_id,
            name=quest_data.name,
            description=quest_data.description,
            image=quest_data.image,
            mentor_preference=quest_data.mentor_preference,
            auto_accrual=quest_data.credits.auto if quest_data.credits else False,
            cost=quest_data.credits.cost if quest_data.credits else 0,
            reward=quest_data.credits.reward if quest_data.credits else 0,
            is_subscription=False,  # Пока не реализовано в схеме
            pay_extra=0,  # Пока не реализовано в схеме
            level=quest_data.main_preferences.level if quest_data.main_preferences else None,
            milage=quest_data.main_preferences.mileage if quest_data.main_preferences else None,
            category_id=quest_data.main_preferences.category_id if quest_data.main_preferences else None,
            vehicle_id=quest_data.main_preferences.vehicle_id if quest_data.main_preferences else None,
            place_id=quest_data.main_preferences.place_id if quest_data.main_preferences else None,
            group=quest_data.main_preferences.group if quest_data.main_preferences else None,
            timeframe=quest_data.main_preferences.timeframe if quest_data.main_preferences else None
        )
        
        # Обновляем квест
        update_result = await quest_service.update_quest(quest_id, quest_update_dto)
        
        if isinstance(update_result, Err):
            return {"error": "Failed to update quest", "details": str(update_result.err())}
        
        quest = update_result.ok()
        
        return {
            "success": True,
            "message": "Quest updated successfully",
            "quest_id": quest.id,
            "quest": {
                "id": quest.id,
                "name": quest.name,
                "description": quest.description,
                "image": quest.image
            }
        }
        
    except Exception as e:
        import traceback
        return {
            "error": f"Internal server error: {str(e)}",
            "traceback": traceback.format_exc()
        }


# Админские эндпоинты для управления квестами
@router.get("/admin/list", response_model=list[QuestAsItem])
@inject
async def get_admin_quests_list(
    quest_service: Injected[QuestService], 
    user: User = Depends(require_edit_quests)
) -> list[QuestAsItem]:
    """Получение списка всех квестов для администраторов с расширенной информацией."""
    quests = await quest_service.get_all_quests()
    return quests

@router.get("/admin/{quest_id}", response_model=QuestReadSchema)
@inject
async def get_admin_quest_detail(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
) -> QuestReadSchema:
    """Получение детальной информации о квесте для администраторов - возвращает все поля."""

    quest_result = await quest_service.get_quest_by_id(quest_id)

    if isinstance(quest_result, Err):
        raise await exceptions_mapper(quest_result.err())
    
    quest = quest_result.ok()
    
    # Получаем все связанные данные
    merch_list = await quest_service.get_merch_list_by_quest_id(quest_id)
    preferences = await quest_service.get_preferences_by_quest_id(quest_id)
    points = await quest_service.get_quest_points_list(quest_id)
    places = await quest_service.get_places_by_quest_id(quest_id)
    
    # Преобразуем данные в формат QuestReadSchema
    merch_schemas = []
    for i, merch_item in enumerate(merch_list):
        merch_schema = {
            "id": merch_item.get("id", 0),
            "description": merch_item.get("description", ""),
            "price": merch_item.get("price", 0),
            "image": merch_item.get("image", "")
        }
        merch_schemas.append(merch_schema)
    
    # Создаем MainPreferences в формате чтения
    main_preferences = MainPreferences(
        category_id=quest.category_id or 1,
        vehicle_id=quest.vehicle_id or 1,
        place_id=quest.place_id or 1,
        group=quest.group or GroupType.ALONE,
        timeframe=quest.timeframe,
        level=quest.level or Level.EASY,
        mileage=quest.milage or Milage.UP_TO_TEN,
        types=[item.get("id", 0) for item in preferences],
        places=[item.get("id", 0) for item in places],
        vehicles=[quest.vehicle_id] if quest.vehicle_id else [],
        tools=[]
    )
    
    # Создаем Credits в формате чтения
    credits = Credits(
        auto=quest.auto_accrual or False,
        cost=quest.cost if quest.cost is not None else 0,
        reward=quest.reward if quest.reward is not None else 0
    )
    
    # Преобразуем точки в формат чтения
    points_schemas = []
    for point in points:
        # Создаем места для точки
        places = []
        if point.get("places"):
            for place in point.get("places", []):
                places.append({
                    "latitude": place.get("latitude", 0.0),
                    "longitude": place.get("longitude", 0.0)
                })
        
        point_schema = {
            "id": point.get("id"),  # Добавляем ID точки
            "name": point.get("name", ""),  # Используем name из get_quest_points_list
            "description": point.get("description", ""),  # Добавляем description
            "order": point.get("order", 0),
            "type_id": point.get("type_id"),  # Добавляем type_id для редактирования
            "tool_id": point.get("tool_id"),  # Добавляем tool_id для редактирования
            "places": places
        }

        points_schemas.append(point_schema)
    
    # Создаем PlaceSettings
    place_settings = PlaceSettingsRead(
        type="default",
        settings=None
    )
    
    # Создаем PriceSettings
    price_settings = PriceSettings(
        type="default",
        is_subscription=quest.is_subscription or False,
        amount=quest.pay_extra or 0.0
    )
    
    return QuestReadSchema(
        id=quest.id,
        title=quest.name or "",
        short_description=quest.description or "",
        full_description=quest.description or "",
        image_url=quest.image or "",
        category_id=quest.category_id or 1,
        category_title=None,  # Можно добавить загрузку из связанной таблицы
        category_image_url=None,  # Можно добавить загрузку из связанной таблицы
        difficulty=quest.level.value if quest.level else "Easy",
        price=quest.pay_extra or 0.0,
        duration=str(quest.timeframe) if quest.timeframe else "1-2 hours",
        player_limit=0,  # Не существует в модели Quest
        age_limit=0,  # Не существует в модели Quest
        is_for_adv_users=False,  # Не существует в модели Quest
        type=str(quest.group) if quest.group else "Solo",
        credits=credits,
        mentor_preference=quest.mentor_preference,  # Добавляем mentor_preference
        merch_list=merch_schemas,
        main_preferences=main_preferences,
        points=points_schemas,
        place_settings=place_settings,
        price_settings=price_settings
    )

@router.post("/admin/create", response_model=QuestParameterModel)
@inject
async def create_admin_quest(
    quest_data: QuestCreteSchema,
    quest_service: Injected[QuestService],
    user: User = Depends(require_create_quests)
) -> QuestParameterModel:
    """Создание нового квеста администратором."""
    quest_dto = QuestCreateDTO(
        name=quest_data.name,
        description=quest_data.description,
        image=quest_data.image,
        category_id=quest_data.main_preferences.category_id,
        level=quest_data.main_preferences.level,
        timeframe=quest_data.main_preferences.timeframe,
        group=quest_data.main_preferences.group,
        cost=quest_data.credits.cost,
        reward=quest_data.credits.reward,
        pay_extra=0,  # TODO: Добавить в схему
        is_subscription=False,  # TODO: Добавить в схему
        vehicle_id=quest_data.main_preferences.vehicle_id,
        place_id=quest_data.main_preferences.place_id,
        milage=quest_data.main_preferences.mileage,
        mentor_preference=quest_data.mentor_preference,
        auto_accrual=False,  # TODO: Добавить в схему
    )
    
    # Создаем DTO для мерча
    merch_dtos = []

    print(f"  - quest_data.merch length: {len(quest_data.merch)}")
    for i, merch_item in enumerate(quest_data.merch):
        print(f"  - merch_item[{i}]: description='{merch_item.description}', price={merch_item.price}, image_length={len(merch_item.image) if merch_item.image else 0}")
        merch_create_dto = MerchCreateDTO(
            description=merch_item.description,
            price=merch_item.price,
            image=merch_item.image,
        )
        merch_dtos.append(merch_create_dto)
    print(f"  - merch_dtos length: {len(merch_dtos)}")
    
    # Создаем DTO для точек
    points_dtos = []
    for point_data in quest_data.points:
        # Конвертируем PlaceSettings в PlaceCreateDTO
        places_dtos = []
        for place_data in point_data.places:
            place_dto = PlaceCreateDTO(
                longitude=place_data.longitude,
                latitude=place_data.latitude,
                detections_radius=place_data.detections_radius,
                height=place_data.height,
                interaction_inaccuracy=place_data.interaction_inaccuracy,
                part=place_data.part,
                random_occurrence=place_data.random_occurrence,
                point_id=None,  # Будет установлено в сервисе
            )
            places_dtos.append(place_dto)
        
        point_dto = PointCreateDTO(
            name_of_location=point_data.name_of_location,
            description=point_data.description,  # Используем данные из схемы
            order=point_data.order,
            type_id=point_data.type_id,  # Теперь это плоское поле
            places=places_dtos,  # Используем конвертированные DTO
            type_photo=None,  # Не передается с фронтенда
            type_code=None,   # Не передается с фронтенда
            type_word=None,   # Не передается с фронтенда
            tool_id=point_data.tool_id,
            file=point_data.file,  # file вместо files
            is_divide=point_data.is_divide,  # Используем данные из схемы
        )
        points_dtos.append(point_dto)
    
    result = await quest_service.create_quest(quest_dto, merch_dtos, points_dtos)
    if isinstance(result, Err):
        raise await exceptions_mapper(result.err())
    
    return result.ok()

@router.put("/admin/update/{quest_id}")
@inject
async def update_admin_quest(
    quest_id: int,
    quest_data: QuestCreteSchema,  # Используем ту же схему, что и в создании
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Обновление квеста администратором (новая логика на основе создания)."""
    
    # Создаем DTO для обновления на основе той же схемы, что и в создании
    quest_dto = QuestUpdateDTO(
        id=quest_id,
        name=quest_data.name,
        description=quest_data.description,
        image=quest_data.image,
        category_id=quest_data.main_preferences.category_id,
        level=quest_data.main_preferences.level,
        timeframe=quest_data.main_preferences.timeframe,
        group=quest_data.main_preferences.group,
        cost=quest_data.credits.cost,
        reward=quest_data.credits.reward,
        # Используем данные из main_preferences.price_settings если они есть, иначе значения по умолчанию
        pay_extra=quest_data.main_preferences.price_settings.amount if hasattr(quest_data.main_preferences, 'price_settings') and quest_data.main_preferences.price_settings else 0,
        is_subscription=quest_data.main_preferences.price_settings.is_subscription if hasattr(quest_data.main_preferences, 'price_settings') and quest_data.main_preferences.price_settings else False,
        vehicle_id=quest_data.main_preferences.vehicle_id,
        place_id=quest_data.main_preferences.place_id,
        milage=quest_data.main_preferences.mileage,
        mentor_preference=quest_data.mentor_preference,
        # Используем данные из credits.auto если они есть, иначе значение по умолчанию
        auto_accrual=quest_data.credits.auto if hasattr(quest_data, 'credits') and quest_data.credits else False,
    )
    
    # Создаем DTO для мерча
    merch_dtos = []
    for merch_item in quest_data.merch:
        merch_update_dto = MerchUpdateDTO(
            id=None,  # Новые элементы при редактировании
            description=merch_item.description,
            price=merch_item.price,
            image=merch_item.image,
        )
        merch_dtos.append(merch_update_dto)
    
    # Создаем DTO для точек (используем PointUpdateDTO для редактирования)
    points_dtos = []
    for point_data in quest_data.points:
        # Конвертируем PlaceSettings в PlaceUpdateDTO
        places_dtos = []
        for place_data in point_data.places:
            place_dto = PlaceUpdateDTO(
                longitude=place_data.longitude,
                latitude=place_data.latitude,
                detections_radius=place_data.detections_radius,
                height=place_data.height,
                interaction_inaccuracy=place_data.interaction_inaccuracy,
                part=place_data.part,
                random_occurrence=place_data.random_occurrence,
                id=None,  # Новые места при редактировании
                point_id=None,  # Будет установлено в сервисе
            )
            places_dtos.append(place_dto)
        
        point_dto = PointUpdateDTO(
            id=None,  # Новые точки при редактировании
            quest_id=quest_id,  # Обязательно для редактирования
            name_of_location=point_data.name_of_location,
            description=point_data.description,
            order=point_data.order,
            type_id=point_data.type_id,
            places=places_dtos,  # Используем конвертированные DTO
            type_photo=None,  # Не передается с фронтенда
            type_code=None,   # Не передается с фронтенда
            type_word=None,   # Не передается с фронтенда
            tool_id=point_data.tool_id,
            file=point_data.file,
            is_divide=point_data.is_divide,
        )
        points_dtos.append(point_dto)
    
    # Вызываем update_quest с правильными параметрами (точно как в создании)
    result = await quest_service.update_quest(quest_dto, merch_dtos, points_dtos)
    if isinstance(result, Err):
        raise await exceptions_mapper(result.err())
    
    # Получаем объект, но не пытаемся его сериализовать
    quest_obj = result.ok()
    
    # Просто возвращаем успешный ответ без попытки сериализации SQLAlchemy модели
    return {"message": "Quest updated successfully", "quest_id": quest_id}

@router.delete("/admin/delete/{quest_id}")
@inject
async def delete_admin_quest(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Удаление квеста администратором."""
    result = await quest_service.delete_quest(quest_id)
    if isinstance(result, Err):
        raise await exceptions_mapper(result.err())
    
    return {"message": "Quest deleted successfully"}

@router.get("/admin/analytics")
@inject
async def get_quests_analytics(
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Получение аналитики по квестам для администраторов."""
    # Получаем базовую статистику
    all_quests = await quest_service.get_all_quests()
    
    # Подсчитываем статистику
    total_quests = len(all_quests)
    active_quests = len([q for q in all_quests if hasattr(q, 'is_active') and q.is_active])
    draft_quests = len([q for q in all_quests if hasattr(q, 'status') and q.status == 'draft'])
    
    # Статистика по категориям
    categories_stats = {}
    for quest in all_quests:
        if hasattr(quest, 'category') and quest.category:
            cat_name = quest.category.name
            categories_stats[cat_name] = categories_stats.get(cat_name, 0) + 1
    
    # Статистика по сложности
    difficulty_stats = {}
    for quest in all_quests:
        if hasattr(quest, 'level') and quest.level:
            diff = str(quest.level.value) if hasattr(quest.level, 'value') else str(quest.level)
            difficulty_stats[diff] = difficulty_stats.get(diff, 0) + 1
    
    return {
        "total_quests": total_quests,
        "active_quests": active_quests,
        "draft_quests": draft_quests,
        "categories_stats": categories_stats,
        "difficulty_stats": difficulty_stats,
        "recent_activity": "Last 7 days",  # Placeholder
        "popular_quests": [],  # Placeholder
        "user_engagement": "High"  # Placeholder
    }

@router.post("/admin/bulk-action")
@inject
async def bulk_action_quests(
    action: str,
    quest_ids: list[int],
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Массовые операции с квестами (активация, деактивация, удаление)."""
    if action == "activate":
        # Активация квестов
        results = []
        for quest_id in quest_ids:
            try:
                # Здесь должна быть логика активации квеста
                results.append({"quest_id": quest_id, "status": "activated"})
            except Exception as e:
                results.append({"quest_id": quest_id, "status": "error", "message": str(e)})
        return {"action": "activate", "results": results}
    
    elif action == "deactivate":
        # Деактивация квестов
        results = []
        for quest_id in quest_ids:
            try:
                # Здесь должна быть логика деактивации квеста
                results.append({"quest_id": quest_id, "status": "deactivated"})
            except Exception as e:
                results.append({"quest_id": quest_id, "status": "error", "message": str(e)})
        return {"action": "deactivate", "results": results}
    
    elif action == "delete":
        # Удаление квестов
        results = []
        for quest_id in quest_ids:
            try:
                result = await quest_service.delete_quest(quest_id)
                if isinstance(result, Err):
                    results.append({"quest_id": quest_id, "status": "error", "message": str(result.err())})
                else:
                    results.append({"quest_id": quest_id, "status": "deleted"})
            except Exception as e:
                results.append({"quest_id": quest_id, "status": "error", "message": str(e)})
        return {"action": "delete", "results": results}
    
    else:
        return {"error": "Invalid action. Supported actions: activate, deactivate, delete"} 

@router.put("/admin/test-update/{quest_id}")
@inject
async def test_update_admin_quest(
    quest_id: int,
    quest_data: dict,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Тестовое обновление квеста администратором."""
    print(f"Received data: {quest_data}")
    return {"message": "Test update received", "data": quest_data} 

@router.put("/admin/simple-update/{quest_id}")
@inject
async def simple_update_admin_quest(
    quest_id: int,
    request: Request,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Простое обновление квеста администратором."""
    try:
        quest_data = await request.json()
        print(f"Received quest data: {quest_data}")
        
        # Создаем DTO для обновления
        quest_dto = QuestUpdateDTO(
            id=quest_id,
            name=quest_data.get('name', ''),
            description=quest_data.get('description', ''),
            image=quest_data.get('image', ''),
            category_id=quest_data.get('category_id', 1),
            level=quest_data.get('level', 'Easy'),
            timeframe=quest_data.get('timeframe', 1),
            group=quest_data.get('group', 1),
            cost=quest_data.get('cost', 0),
            reward=quest_data.get('reward', 0),
            pay_extra=0,
            is_subscription=False,
            vehicle_id=quest_data.get('vehicle_id', 1),
            place_id=quest_data.get('place_id', 1),
            milage=quest_data.get('mileage', '5-10'),
            mentor_preference=quest_data.get('mentor_preference', ''),
            auto_accrual=False,
        )
        
        # Вызываем update_quest
        quest_update_result = await quest_service.update_quest(
            quest_dto=quest_dto,
            merchs_dtos=[],
            points_dtos=[],
        )
        
        if isinstance(quest_update_result, Err):
            return {"error": str(quest_update_result.err())}
        
        return {"message": "Quest updated successfully", "id": quest_id, "name": quest_data.get('name')}
        
    except Exception as e:
        print(f"Error in simple_update_admin_quest: {e}")
        return {"error": str(e)} 

@router.get("/admin/test-simple")
async def test_simple():
    """Простой тестовый роут."""
    return {"message": "Test simple route works"} 

@router.get("/admin/test-minimal")
async def test_minimal():
    """Минимальный тестовый роут."""
    return {"status": "ok"} 

# Удаляем сложный эндпоинт для mock изображений
# Вместо этого будем возвращать base64 в ответе API 