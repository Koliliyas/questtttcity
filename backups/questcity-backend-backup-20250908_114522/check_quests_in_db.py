#!/usr/bin/env python3
"""
Скрипт для проверки квестов в базе данных
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def check_quests_in_db():
    """Проверяем квесты в базе данных"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔍 Проверяем квесты в базе данных")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Получаем все квесты
        quests_query = """
        SELECT id, name, description, category_id, level, timeframe, "group", 
               cost, reward, pay_extra, is_subscription, vehicle_id,
               mentor_preference, auto_accrual, milage, place_id
        FROM quest
        ORDER BY id
        """
        
        quests = await conn.fetch(quests_query)
        
        print(f"📊 Всего квестов в базе: {len(quests)}")
        print()
        
        if len(quests) == 0:
            print("❌ Квестов в базе данных нет!")
            print("\n🔧 Возможные причины:")
            print("  1. Квесты не были созданы")
            print("  2. Квесты были удалены")
            print("  3. Проблема с правами доступа")
            return
        
        for quest in quests:
            print(f"🎯 Квест ID {quest['id']}:")
            print(f"   - Название: {quest['name']}")
            print(f"   - Описание: {quest['description'][:50]}...")
            print(f"   - Категория ID: {quest['category_id']}")
            print(f"   - Уровень: {quest['level']}")
            print(f"   - Временные рамки: {quest['timeframe']}")
            print(f"   - Группа: {quest['group']}")
            print(f"   - Стоимость: {quest['cost']}")
            print(f"   - Награда: {quest['reward']}")
            print()
        
        # Проверяем связанные таблицы
        print("🔍 Проверяем связанные таблицы:")
        
        # Точки квестов
        points_query = "SELECT COUNT(*) FROM point"
        points_count = await conn.fetchval(points_query)
        print(f"   - Точки квестов: {points_count}")
        
        # Места
        places_query = "SELECT COUNT(*) FROM place"
        places_count = await conn.fetchval(places_query)
        print(f"   - Места: {places_count}")
        
        # Настройки мест
        place_settings_query = "SELECT COUNT(*) FROM place_settings"
        place_settings_count = await conn.fetchval(place_settings_query)
        print(f"   - Настройки мест: {place_settings_count}")
        
        # Мерч
        merch_query = "SELECT COUNT(*) FROM merch"
        merch_count = await conn.fetchval(merch_query)
        print(f"   - Мерч: {merch_count}")
        
        # Категории
        categories_query = "SELECT COUNT(*) FROM category"
        categories_count = await conn.fetchval(categories_query)
        print(f"   - Категории: {categories_count}")
        
        # Транспорт
        vehicles_query = "SELECT COUNT(*) FROM vehicle"
        vehicles_count = await conn.fetchval(vehicles_query)
        print(f"   - Транспорт: {vehicles_count}")
        
        # Места (place)
        place_table_query = "SELECT COUNT(*) FROM place"
        place_table_count = await conn.fetchval(place_table_query)
        print(f"   - Таблица place: {place_table_count}")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при проверке квестов: {e}")

if __name__ == "__main__":
    asyncio.run(check_quests_in_db())
