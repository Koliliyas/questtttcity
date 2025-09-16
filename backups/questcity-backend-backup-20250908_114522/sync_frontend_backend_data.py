#!/usr/bin/env python3
"""
Синхронизация данных фронтенда и бэкенда для activity и tool
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def sync_frontend_backend_data():
    """Синхронизируем данные activity и tool с фронтендом"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔄 Синхронизация данных фронтенда и бэкенда")
    print(f"🔗 Подключение: {database_host}:{database_port}/{database_name}")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Очищаем существующие данные
        print("\n🗑️  Очищаем существующие данные...")
        await conn.execute("DELETE FROM tool")
        await conn.execute("DELETE FROM activity")
        
        # Создаем activity в соответствии с фронтендом
        print("\n📋 Создаем activity в соответствии с фронтендом:")
        activities = [
            "Catch a ghost",           # ID 1
            "Take a photo",            # ID 2
            "Download the file",       # ID 3
            "Scan Qr-code",            # ID 4
            "Enter the code",          # ID 5
            "Enter the word",          # ID 6
            "Pick up an artifact",     # ID 7
        ]
        
        for i, activity_name in enumerate(activities, 1):
            await conn.execute(
                "INSERT INTO activity (id, name) VALUES ($1, $2)",
                i, activity_name
            )
            print(f"  ✅ ID {i}: {activity_name}")
        
        # Создаем tool в соответствии с фронтендом
        print("\n📋 Создаем tool в соответствии с фронтендом:")
        tools = [
            ("None", "none.jpg"),                           # ID 1
            ("Screen illustration descriptor", "screen.jpg"), # ID 2
            ("Beeping radar", "beeping_radar.jpg"),         # ID 3
            ("Orbital radar", "orbital_radar.jpg"),         # ID 4
            ("Mile orbital radar", "mile_orbital.jpg"),     # ID 5
            ("Unlim orbital radar", "unlim_orbital.jpg"),   # ID 6
            ("Target compass", "target_compass.jpg"),       # ID 7
            ("Rangefinder", "rangefinder.jpg"),             # ID 8
            ("Rangefinder unlim", "rangefinder_unlim.jpg"), # ID 9
            ("Echolocation screen", "echolocation.jpg"),    # ID 10
            ("QR scanner", "qr_scanner.jpg"),               # ID 11
            ("Camera tool", "camera_tool.jpg"),             # ID 12
            ("Word locker", "word_locker.jpg"),             # ID 13
        ]
        
        for i, (tool_name, tool_image) in enumerate(tools, 1):
            await conn.execute(
                "INSERT INTO tool (id, name, image) VALUES ($1, $2, $3)",
                i, tool_name, tool_image
            )
            print(f"  ✅ ID {i}: {tool_name} (image: {tool_image})")
        
        # Проверяем результат
        print("\n🔍 Проверяем результат:")
        
        activities_result = await conn.fetch("SELECT id, name FROM activity ORDER BY id")
        print(f"  📊 Activity: {len(activities_result)} записей")
        for activity in activities_result:
            print(f"    - ID {activity['id']}: {activity['name']}")
        
        tools_result = await conn.fetch("SELECT id, name, image FROM tool ORDER BY id")
        print(f"  📊 Tool: {len(tools_result)} записей")
        for tool in tools_result:
            print(f"    - ID {tool['id']}: {tool['name']} (image: {tool['image']})")
        
        await conn.close()
        print("\n🎉 Синхронизация завершена успешно!")
        
    except Exception as e:
        print(f"❌ Ошибка при синхронизации: {e}")

if __name__ == "__main__":
    asyncio.run(sync_frontend_backend_data())
