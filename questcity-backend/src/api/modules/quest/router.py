"""
Главный роутер для квестов.

Объединяет все суброутеры для различных операций с квестами:
- Основные операции с квестами
- Управление категориями
- Управление местами
- Управление транспортом
- Управление типами активности
- Управление инструментами
"""

from fastapi import APIRouter

from src.api.modules.quest.routers import (
    quests,
    categories,
    places,
    vehicles,
    activities,
    tools,
    points,
)

router = APIRouter()

# Подключение суброутеров
router.include_router(quests.router, tags=["quests"])
router.include_router(categories.router, prefix="/categories", tags=["categories"])
router.include_router(places.router, prefix="/places", tags=["places"])
router.include_router(vehicles.router, prefix="/vehicles", tags=["vehicles"])
router.include_router(activities.router, prefix="/types", tags=["activities"])
router.include_router(tools.router, prefix="/tools", tags=["tools"])
router.include_router(points.router, prefix="/quests", tags=["quest_points"])
