#!/usr/bin/env python3
"""
Скрипт для прямого тестирования функции get_merch_list_by_quest_id
"""

import asyncio
import os
import sys

# Добавляем путь к модулям проекта
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

async def test_merch_service_direct():
    """Прямое тестирование функции get_merch_list_by_quest_id"""
    
    print("🧪 Прямое тестирование функции get_merch_list_by_quest_id")
    
    try:
        from src.core.quest.services import QuestService
        from src.core.quest.repository import QuestRepository
        from src.core.repositories import S3Repository
        from src.db.engine import get_async_session
        
        # Создаем сессию
        session = await anext(get_async_session())
        
        # Создаем сервисы
        quest_repository = QuestRepository(session)
        s3_repository = S3Repository()
        quest_service = QuestService(quest_repository, s3_repository)
        
        # Тестируем функцию
        print(f"\n🔍 Тестируем get_merch_list_by_quest_id для quest_id=64...")
        merch_list = await quest_service.get_merch_list_by_quest_id(64)
        
        print(f"📊 Результат:")
        print(f"  - merch_list length: {len(merch_list)}")
        for i, merch_item in enumerate(merch_list):
            print(f"  - merch_item[{i}]: {merch_item}")
            
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_merch_service_direct())
















