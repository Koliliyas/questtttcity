import aioinject
import os

from src.core.di._types import Providers
from src.core.quest.repositories import (CategoryRepository,
                                     PlacePreferenceRepository,
                                     PlaceRepository, PointRepository,
                                     QuestRepository, ReviewRepository,
                                     ToolRepository, TypeRepository,
                                     VehicleRepository)
from src.core.quest.services import ItemService, QuestService, ReviewService

# Создаем мок-сервисы для разработки
class MockItemService:
    """Мок-сервис для элементов квестов без S3"""
    
    async def get_items(self, repository: str):
        return []
    
    async def create_item(self, service_name: str, dto):
        return None
    
    async def update_item(self, item_name: str, data, oid: int):
        return None

class MockQuestService:
    """Мок-сервис для квестов без S3"""
    
    async def get_all_quests(self):
        return []
    
    async def get_quest(self, oid: int, me: bool = False):
        return None
    
    async def get_quest_by_id(self, quest_id: int):
        return None

# Функции для создания сервисов
def create_item_service():
    """Создает ItemService в зависимости от окружения"""
    if os.getenv("ENVIRONMENT", "development") == "production":
        return ItemService
    else:
        return MockItemService

def create_quest_service():
    """Создает QuestService в зависимости от окружения"""
    if os.getenv("ENVIRONMENT", "development") == "production":
        return QuestService
    else:
        return MockQuestService

PROVIDERS: Providers = [
    aioinject.Scoped(ReviewRepository),
    aioinject.Scoped(CategoryRepository),
    aioinject.Scoped(PlacePreferenceRepository),
    aioinject.Scoped(PlaceRepository),
    aioinject.Scoped(PointRepository),
    aioinject.Scoped(QuestRepository),
    aioinject.Scoped(ToolRepository),
    aioinject.Scoped(TypeRepository),
    aioinject.Scoped(VehicleRepository),
    aioinject.Scoped(QuestService),
    aioinject.Scoped(ItemService),
    aioinject.Scoped(ReviewService),
]
