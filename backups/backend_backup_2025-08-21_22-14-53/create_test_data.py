#!/usr/bin/env python3
"""
Создание тестовых данных для проверки удаления квестов
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def create_test_data():
    """Создаем тестовые данные"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🧪 Создаем тестовые данные")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Проверяем, есть ли уже данные
        activity_count = await conn.fetchval("SELECT COUNT(*) FROM activity")
        tool_count = await conn.fetchval("SELECT COUNT(*) FROM tool")
        
        print(f"📊 Текущее состояние:")
        print(f"  - activity: {activity_count} записей")
        print(f"  - tool: {tool_count} записей")
        
        # Создаем activity если нет
        if activity_count == 0:
            await conn.execute("""
                INSERT INTO activity (name) VALUES 
                ('Тестовая активность 1'),
                ('Тестовая активность 2'),
                ('Тестовая активность 3')
            """)
            print("✅ Созданы тестовые записи в таблице activity")
        
        # Создаем tool если нет
        if tool_count == 0:
            await conn.execute("""
                INSERT INTO tool (name, image) VALUES 
                ('Тестовый инструмент 1', 'tool1.jpg'),
                ('Тестовый инструмент 2', 'tool2.jpg'),
                ('Тестовый инструмент 3', 'tool3.jpg')
            """)
            print("✅ Созданы тестовые записи в таблице tool")
        
        # Проверяем результат
        activity_count = await conn.fetchval("SELECT COUNT(*) FROM activity")
        tool_count = await conn.fetchval("SELECT COUNT(*) FROM tool")
        
        print(f"\n📊 Итоговое состояние:")
        print(f"  - activity: {activity_count} записей")
        print(f"  - tool: {tool_count} записей")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при создании тестовых данных: {e}")

if __name__ == "__main__":
    asyncio.run(create_test_data())
