#!/usr/bin/env python3
"""
Проверка данных в таблицах activity и tool
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def check_activity_tool_data():
    """Проверяем данные в таблицах activity и tool"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔍 Проверяем данные в таблицах activity и tool")
    print(f"🔗 Подключение: {database_host}:{database_port}/{database_name}")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Проверяем таблицу activity
        print("\n📋 Таблица 'activity':")
        activities = await conn.fetch("SELECT id, name FROM activity ORDER BY id")
        
        if activities:
            for activity in activities:
                print(f"  - ID {activity['id']}: {activity['name']}")
        else:
            print("  ❌ Нет данных в таблице activity")
        
        # Проверяем таблицу tool
        print("\n📋 Таблица 'tool':")
        tools = await conn.fetch("SELECT id, name, image FROM tool ORDER BY id")
        
        if tools:
            for tool in tools:
                print(f"  - ID {tool['id']}: {tool['name']} (image: {tool['image']})")
        else:
            print("  ❌ Нет данных в таблице tool")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при проверке: {e}")

if __name__ == "__main__":
    asyncio.run(check_activity_tool_data())
