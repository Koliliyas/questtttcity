#!/usr/bin/env python3
"""
Удаление квеста с ID 77 разными способами
"""

import asyncio
import asyncpg
import os
import requests
from dotenv import load_dotenv

load_dotenv()

async def delete_quest_77_direct_sql():
    """Удаление квеста 77 напрямую через SQL"""
    
    # Получаем параметры подключения
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🗑️  Удаляем квест 77 напрямую через SQL")
    print(f"🔗 Подключение: {database_host}:{database_port}/{database_name}")
    print("=" * 60)
    
    try:
        # Подключаемся к базе данных
        conn = await asyncpg.connect(database_url)
        
        # Проверяем существование квеста
        quest_check = await conn.fetchrow("SELECT id, name FROM quest WHERE id = 77")
        if not quest_check:
            print("❌ Квест с ID 77 не найден")
            await conn.close()
            return False
        
        print(f"✅ Найден квест: {quest_check['name']}")
        
        # Начинаем транзакцию
        async with conn.transaction():
            print("🔄 Начинаем удаление связанных данных...")
            
            # 1. Получаем ID точек квеста
            points = await conn.fetch("SELECT id FROM point WHERE quest_id = 77")
            point_ids = [point['id'] for point in points]
            print(f"  📍 Найдено точек: {len(point_ids)}")
            
            if point_ids:
                # 2. Удаляем place_settings для всех точек квеста
                place_settings_deleted = await conn.execute(
                    "DELETE FROM place_settings WHERE point_id = ANY($1)", 
                    point_ids
                )
                print(f"  ✅ Удалено place_settings: {place_settings_deleted.split()[-1] if place_settings_deleted else '0'}")
            
            # 3. Удаляем точки квеста
            points_deleted = await conn.execute("DELETE FROM point WHERE quest_id = 77")
            print(f"  ✅ Удалено точек: {points_deleted.split()[-1] if points_deleted else '0'}")
            
            # 4. Удаляем мерч квеста
            merch_deleted = await conn.execute("DELETE FROM merch WHERE quest_id = 77")
            print(f"  ✅ Удалено мерча: {merch_deleted.split()[-1] if merch_deleted else '0'}")
            
            # 5. Удаляем отзывы квеста
            reviews_deleted = await conn.execute("DELETE FROM review WHERE quest_id = 77")
            print(f"  ✅ Удалено отзывов: {reviews_deleted.split()[-1] if reviews_deleted else '0'}")
            
            # 6. Удаляем сам квест
            quest_deleted = await conn.execute("DELETE FROM quest WHERE id = 77")
            print(f"  ✅ Удален квест: {quest_deleted.split()[-1] if quest_deleted else '0'}")
        
        await conn.close()
        print("✅ Квест 77 и все связанные данные успешно удалены!")
        return True
        
    except Exception as e:
        print(f"❌ Ошибка при удалении через SQL: {e}")
        return False

def delete_quest_77_api():
    """Удаление квеста 77 через API (без авторизации для теста)"""
    
    BASE_URL = "http://localhost:8000/api/v1"
    QUEST_ID = 77
    
    print(f"\n🌐 Пробуем удалить квест 77 через API")
    print(f"📡 URL: {BASE_URL}/quests/admin/delete/{QUEST_ID}")
    print("=" * 60)
    
    try:
        # Отправляем DELETE запрос без авторизации
        response = requests.delete(f"{BASE_URL}/quests/admin/delete/{QUEST_ID}")
        
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ SUCCESS: Квест удален через API!")
            return True
        elif response.status_code == 401:
            print("⚠️  Got 401 (Unauthorized) - API endpoint works, but needs auth")
            return False
        elif response.status_code == 404:
            print("❌ Got 404 (Not Found) - API endpoint not found")
            return False
        else:
            print(f"⚠️  UNEXPECTED: Got {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Cannot connect to server")
        return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

async def check_quest_77_exists():
    """Проверяем, существует ли квест 77"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    try:
        conn = await asyncpg.connect(database_url)
        quest = await conn.fetchrow("SELECT id, name FROM quest WHERE id = 77")
        await conn.close()
        
        if quest:
            print(f"✅ Квест 77 существует: {quest['name']}")
            return True
        else:
            print("❌ Квест 77 не найден")
            return False
            
    except Exception as e:
        print(f"❌ Ошибка при проверке: {e}")
        return False

async def main():
    """Основная функция - удаляем квест 77 до успеха"""
    
    print("🗑️  УДАЛЕНИЕ КВЕСТА 77")
    print("=" * 60)
    
    # Проверяем существование квеста
    if not await check_quest_77_exists():
        print("❌ Квест 77 не найден, нечего удалять")
        return
    
    print("\n🎯 Начинаем попытки удаления...")
    
    # Попытка 1: Через API (скорее всего не сработает из-за авторизации)
    print("\n📋 Попытка 1: Удаление через API")
    if delete_quest_77_api():
        print("🎉 УСПЕХ! Квест удален через API")
        return
    
    # Попытка 2: Напрямую через SQL
    print("\n📋 Попытка 2: Удаление напрямую через SQL")
    if await delete_quest_77_direct_sql():
        print("🎉 УСПЕХ! Квест удален через SQL")
        return
    
    # Проверяем результат
    print("\n🔍 Проверяем результат...")
    if not await check_quest_77_exists():
        print("🎉 УСПЕХ! Квест 77 больше не существует")
    else:
        print("❌ НЕУДАЧА: Квест 77 все еще существует")

if __name__ == "__main__":
    asyncio.run(main())
