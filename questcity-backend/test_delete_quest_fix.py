#!/usr/bin/env python3
"""
Тест для проверки исправления удаления квеста с связанными точками
"""

import asyncio
import sys
import os

# Добавляем путь к src
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from src.core.quest.services import QuestService
from src.db.repositories import QuestRepository, PointRepository
from src.db.dependencies import create_session
from src.db.models.quest.quest import Quest
from src.db.models.quest.point import Point
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

async def test_delete_quest_with_points():
    """Тест удаления квеста с связанными точками"""
    
    # Создаем сессию БД
    async with create_session() as session:
        try:
            # Создаем репозитории
            quest_repo = QuestRepository(session, Quest)
            point_repo = PointRepository(session, Point)
            
            # Создаем тестовый квест
            test_quest = Quest(
                name="Test Quest for Delete",
                description="Test quest description",
                image="test.jpg",
                mentor_preference="test.xlsx",
                auto_accrual=True,
                cost=100,
                reward=200,
                category_id=1,
                group="TWO",
                vehicle_id=1,
                is_subscription=False,
                pay_extra=0,
                level="EASY",
                milage="UP_TO_TEN",
                place_id=1
            )
            
            # Сохраняем квест
            session.add(test_quest)
            await session.flush()
            quest_id = test_quest.id
            
            print(f"✅ Создан тестовый квест с ID: {quest_id}")
            
            # Создаем тестовую точку для квеста
            test_point = Point(
                name_of_location="Test Point",
                order=1,
                description="Test point description",
                type_id=1,
                quest_id=quest_id
            )
            
            # Сохраняем точку
            session.add(test_point)
            await session.flush()
            point_id = test_point.id
            
            print(f"✅ Создана тестовая точка с ID: {point_id} для квеста {quest_id}")
            
            # Проверяем, что точка создана
            point_check = await session.execute(
                select(Point).where(Point.id == point_id)
            )
            point_check = point_check.scalar_one_or_none()
            
            if point_check:
                print(f"✅ Точка найдена в БД: {point_check.name_of_location}")
            else:
                print("❌ Точка не найдена в БД")
                return
            
            # Создаем сервис
            quest_service = QuestService(
                merch_service=None,  # Мок
                point_repository=point_repo,
                place_preference_repository=None,  # Мок
                quest_repository=quest_repo,
                items_service=None,  # Мок
                s3=None  # Мок
            )
            
            # Пытаемся удалить квест
            print(f"🔄 Пытаемся удалить квест {quest_id}...")
            result = await quest_service.delete_quest(quest_id)
            
            if hasattr(result, 'is_ok') and result.is_ok():
                print(f"✅ Квест {quest_id} успешно удален!")
                
                # Проверяем, что точка тоже удалена
                point_check_after = await session.execute(
                    select(Point).where(Point.id == point_id)
                )
                point_check_after = point_check_after.scalar_one_or_none()
                
                if point_check_after is None:
                    print(f"✅ Точка {point_id} также удалена (каскадное удаление работает)")
                else:
                    print(f"❌ Точка {point_id} не удалена (каскадное удаление не работает)")
                    
            else:
                print(f"❌ Ошибка при удалении квеста: {result}")
                
        except Exception as e:
            print(f"❌ Ошибка в тесте: {e}")
            import traceback
            traceback.print_exc()
        finally:
            # Откатываем изменения
            await session.rollback()
            print("🔄 Откат изменений")

if __name__ == "__main__":
    print("🧪 Запуск теста удаления квеста с связанными точками...")
    asyncio.run(test_delete_quest_with_points())
    print("🏁 Тест завершен")








