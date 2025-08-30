#!/usr/bin/env python3
"""
Финальный тест API квестов
"""

import asyncio
import json
import os
import sys
from pathlib import Path

# Добавляем путь к src в PYTHONPATH
sys.path.insert(0, str(Path(__file__).parent / "src"))

from src.core.quest.services import QuestService
from src.core.quest.repositories import QuestRepository
from src.core.quest.dto import QuestCreateDTO, QuestUpdateDTO
from src.db.models.quest.quest import Quest
from src.db.dependencies import create_session
from src.core.repositories import S3Repository
from src.core.merch.service import MerchService
from src.core.merch.repository import MerchRepository



async def test_quest_service():
    """Тестируем сервис квестов"""
    print("🧪 Тестирование сервиса квестов...")
    
    # Создаем сессию БД
    async with create_session() as session:
        try:
            # Инициализируем сервисы
            quest_repo = QuestRepository(session)
            s3_service = S3Repository()
            merch_repo = MerchRepository(session)
            merch_service = MerchService(merch_repo, s3_service)
            
            quest_service = QuestService(
                quest_repo, 
                s3_service, 
                merch_service, 
                None,  # point_repo
                None   # place_pref_service
            )
            
            # Тест 1: Создание квеста с mock изображением
            print("\n📝 Тест 1: Создание квеста с mock изображением")
            
            quest_data = QuestCreateDTO(
                title="Тестовый квест с изображением",
                description="Описание тестового квеста",
                image="test_image.png",  # Путь к файлу
                mentor_preference="mentor_avatar.jpg",  # Путь к файлу
                price=100.0,
                duration=120,
                max_participants=10,
                min_participants=2,
                difficulty_level="EASY",
                category="ADVENTURE",
                location="Москва",
                latitude=55.7558,
                longitude=37.6176,
                is_active=True,
                is_featured=False,
                tags=["тест", "приключение"],
                requirements=["Возраст 18+", "Удобная обувь"],
                included_items=["Карта", "Компас"],
                not_included_items=["Еда", "Вода"],
                cancellation_policy="Бесплатная отмена за 24 часа",
                safety_measures=["Инструктаж", "Страховка"],
                group_type="PUBLIC"
            )
            
            result = await quest_service.create_quest(quest_data)
            
            if hasattr(result, 'value'):
                quest = result.value
                print(f"✅ Квест создан успешно!")
                print(f"   ID: {quest.id}")
                print(f"   Название: {quest.title}")
                print(f"   Изображение: {quest.image}")
                print(f"   Mentor preference: {quest.mentor_preference}")
                
                # Тест 2: Обновление квеста
                print("\n📝 Тест 2: Обновление квеста")
                
                update_data = QuestUpdateDTO(
                    title="Обновленный тестовый квест",
                    description="Обновленное описание",
                    image="updated_image.png",  # Новый путь к файлу
                    mentor_preference="updated_mentor.jpg",  # Новый путь к файлу
                    price=150.0,
                    duration=180,
                    max_participants=15,
                    min_participants=3,
                    difficulty_level="MEDIUM",
                    category="MYSTERY",
                    location="Санкт-Петербург",
                    latitude=59.9311,
                    longitude=30.3609,
                    is_active=True,
                    is_featured=True,
                    tags=["обновленный", "мистика"],
                    requirements=["Возраст 21+", "Фонарик"],
                    included_items=["Карта", "Компас", "Фонарик"],
                    not_included_items=["Еда", "Вода", "Спальник"],
                    cancellation_policy="Бесплатная отмена за 48 часов",
                    safety_measures=["Инструктаж", "Страховка", "Связь"],
                    group_type="PRIVATE"
                )
                
                update_result = await quest_service.update_quest(quest.id, update_data)
                
                if hasattr(update_result, 'value'):
                    updated_quest = update_result.value
                    print(f"✅ Квест обновлен успешно!")
                    print(f"   Новое название: {updated_quest.title}")
                    print(f"   Новое изображение: {updated_quest.image}")
                    print(f"   Новый mentor preference: {updated_quest.mentor_preference}")
                    print(f"   Новая цена: {updated_quest.price}")
                    print(f"   Новая категория: {updated_quest.category}")
                    print(f"   Новое местоположение: {updated_quest.location}")
                else:
                    print(f"❌ Ошибка обновления: {update_result}")
                
                # Тест 3: Получение квеста по ID
                print("\n📝 Тест 3: Получение квеста по ID")
                
                get_result = await quest_service.get_quest_by_id(quest.id)
                
                if hasattr(get_result, 'value'):
                    retrieved_quest = get_result.value
                    print(f"✅ Квест получен успешно!")
                    print(f"   ID: {retrieved_quest.id}")
                    print(f"   Название: {retrieved_quest.title}")
                    print(f"   Изображение: {retrieved_quest.image}")
                    print(f"   Mentor preference: {retrieved_quest.mentor_preference}")
                else:
                    print(f"❌ Ошибка получения: {get_result}")
                
                # Тест 4: Получение всех квестов
                print("\n📝 Тест 4: Получение всех квестов")
                
                all_quests_result = await quest_service.get_all_quests()
                
                if hasattr(all_quests_result, 'value'):
                    all_quests = all_quests_result.value
                    print(f"✅ Получено квестов: {len(all_quests)}")
                    for i, q in enumerate(all_quests[:3]):  # Показываем первые 3
                        print(f"   {i+1}. {q.title} - {q.image}")
                else:
                    print(f"❌ Ошибка получения всех квестов: {all_quests_result}")
                
                # Тест 5: Удаление квеста
                print("\n📝 Тест 5: Удаление квеста")
                
                delete_result = await quest_service.delete_quest(quest.id)
                
                if hasattr(delete_result, 'value'):
                    print(f"✅ Квест удален успешно!")
                else:
                    print(f"❌ Ошибка удаления: {delete_result}")
                
            else:
                print(f"❌ Ошибка создания квеста: {result}")
                
        except Exception as e:
            print(f"❌ Ошибка в тесте: {e}")
            import traceback
            traceback.print_exc()


async def test_image_processing():
    """Тестируем обработку изображений"""
    print("\n🖼️ Тестирование обработки изображений...")
    
    async with create_session() as session:
        try:
            quest_repo = QuestRepository(session)
            s3_service = S3Repository()
            merch_repo = MerchRepository(session)
            merch_service = MerchService(merch_repo, s3_service)
            
            quest_service = QuestService(
                quest_repo, 
                s3_service, 
                merch_service, 
                None,  # point_repo
                None   # place_pref_service
            )
            
            # Тест с base64 изображением
            print("\n📝 Тест с base64 изображением")
            
            # Создаем простой base64 изображение (1x1 пиксель, прозрачный PNG)
            base64_image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
            
            quest_data = QuestCreateDTO(
                title="Квест с base64 изображением",
                description="Тест base64 изображения",
                image=base64_image,
                mentor_preference=base64_image,
                price=50.0,
                duration=60,
                max_participants=5,
                min_participants=1,
                difficulty_level="EASY",
                category="TEST",
                location="Тест",
                latitude=0.0,
                longitude=0.0,
                is_active=True,
                is_featured=False,
                tags=["base64", "тест"],
                requirements=[],
                included_items=[],
                not_included_items=[],
                cancellation_policy="",
                safety_measures=[],
                group_type="PUBLIC"
            )
            
            result = await quest_service.create_quest(quest_data)
            
            if hasattr(result, 'value'):
                quest = result.value
                print(f"✅ Квест с base64 создан успешно!")
                print(f"   Изображение: {quest.image}")
                print(f"   Mentor preference: {quest.mentor_preference}")
                
                # Удаляем тестовый квест
                await quest_service.delete_quest(quest.id)
                print(f"✅ Тестовый квест удален")
            else:
                print(f"❌ Ошибка создания квеста с base64: {result}")
                
        except Exception as e:
            print(f"❌ Ошибка в тесте изображений: {e}")
            import traceback
            traceback.print_exc()


async def main():
    """Главная функция"""
    print("🚀 Запуск финального тестирования API квестов")
    print("=" * 50)
    
    # Устанавливаем переменную окружения для разработки
    os.environ["ENVIRONMENT"] = "development"
    
    await test_quest_service()
    await test_image_processing()
    
    print("\n" + "=" * 50)
    print("✅ Тестирование завершено!")


if __name__ == "__main__":
    asyncio.run(main())
