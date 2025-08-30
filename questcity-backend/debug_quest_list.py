import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from src.db.database import get_session
from sqlalchemy import text

async def debug_quest_list():
    print("🚀 Отлаживаем список квестов...")
    print("🔍 Отладка проблемы с отображением квестов в списке админа...")
    
    async with get_session() as sess:
        print("  🔍 Проверяем все квесты в базе данных...")
        try:
            result = await sess.execute(text("""
                SELECT id, name, description, image, created_at, updated_at
                FROM quest
                ORDER BY created_at DESC
            """))
            
            quests = result.fetchall()
            print(f"  ✅ Найдено квестов: {len(quests)}")
            
            print("\n  📋 Детальная информация о квестах:")
            for quest in quests[:10]:  # Показываем первые 10
                print(f"    ID: {quest.id}")
                print(f"    Name: {quest.name}")
                print(f"    Image: '{quest.image}'")
                print(f"    Image length: {len(quest.image) if quest.image else 0}")
                print("    ---")
                
        except Exception as e:
            print(f"  ❌ Ошибка: {e}")

if __name__ == "__main__":
    asyncio.run(debug_quest_list())






