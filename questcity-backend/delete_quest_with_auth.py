#!/usr/bin/env python3
"""
Удаление квеста с авторизацией до успеха
"""

import asyncio
import asyncpg
import os
import requests
import time
from dotenv import load_dotenv

load_dotenv()

def get_admin_token():
    """Получаем токен админа из файла"""
    try:
        with open('.admin_token', 'r') as f:
            token = f.read().strip()
            print(f"✅ Токен получен: {token[:50]}...")
            return token
    except Exception as e:
        print(f"❌ Ошибка при чтении токена: {e}")
        return None

async def create_test_quest():
    """Создаем тестовый квест для проверки удаления"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🧪 Создаем тестовый квест для проверки удаления")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Создаем тестовый квест
        quest_query = """
        INSERT INTO quest (name, description, image, category_id, level, timeframe, 
                          "group", cost, reward, pay_extra, is_subscription, vehicle_id,
                          mentor_preference, auto_accrual, milage, place_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
        RETURNING id
        """
        
        quest_result = await conn.fetchrow(quest_query, 
            f"Тестовый квест для удаления {int(time.time())}",  # name
            "Описание тестового квеста",     # description
            "test_image.jpg",               # image
            1,                              # category_id
            "EASY",                         # level (enum)
            "ONE_HOUR",                     # timeframe (enum)
            "ALONE",                        # group (enum)
            100,                            # cost
            200,                            # reward
            0,                              # pay_extra (integer)
            False,                          # is_subscription
            1,                              # vehicle_id
            "test_mentor",                  # mentor_preference
            True,                           # auto_accrual
            "UP_TO_TEN",                    # milage (enum)
            1                               # place_id
        )
        
        quest_id = quest_result['id']
        print(f"✅ Создан тестовый квест с ID: {quest_id}")
        
        # Проверяем существующие записи в связанных таблицах
        activity_result = await conn.fetchrow("SELECT id FROM activity LIMIT 1")
        tool_result = await conn.fetchrow("SELECT id FROM tool LIMIT 1")
        
        if activity_result and tool_result:
            # Создаем тестовую точку
            point_query = """
            INSERT INTO point (name_of_location, description, "order", type_id, tool_id, 
                              file, is_divide, quest_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING id
            """
            
            point_result = await conn.fetchrow(point_query,
                "Тестовая точка",               # name_of_location
                "Описание тестовой точки",      # description
                1,                              # order
                activity_result['id'],          # type_id
                tool_result['id'],              # tool_id
                "test_file.txt",                # file
                False,                          # is_divide
                quest_id                        # quest_id
            )
            
            point_id = point_result['id']
            print(f"✅ Создана тестовая точка с ID: {point_id}")
            
            # Создаем place_settings для точки
            place_settings_query = """
            INSERT INTO place_settings (longitude, latitude, detections_radius, height, 
                                       random_occurrence, interaction_inaccuracy, part, point_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """
            
            await conn.execute(place_settings_query,
                55.7558,                        # longitude
                37.6176,                        # latitude
                100.0,                          # detections_radius
                10.0,                           # height
                0.5,                            # random_occurrence
                5.0,                            # interaction_inaccuracy
                1,                              # part
                point_id                        # point_id
            )
            
            print(f"✅ Созданы place_settings для точки {point_id}")
        else:
            print("⚠️  Не найдены записи в таблицах activity или tool, создаем квест без точек")
        
        await conn.close()
        return quest_id
        
    except Exception as e:
        print(f"❌ Ошибка при создании тестового квеста: {e}")
        return None

def test_delete_api_with_auth(quest_id, token):
    """Тестируем удаление квеста через API с авторизацией"""
    
    BASE_URL = "http://localhost:8000/api/v1"
    
    print(f"\n🌐 Тестируем удаление квеста {quest_id} через API с авторизацией")
    print(f"📡 URL: {BASE_URL}/quests/admin/delete/{quest_id}")
    print("=" * 60)
    
    try:
        # Заголовки с авторизацией
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        
        # Отправляем DELETE запрос с авторизацией
        response = requests.delete(f"{BASE_URL}/quests/admin/delete/{quest_id}", headers=headers)
        
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ SUCCESS: Квест удален через API!")
            return True
        elif response.status_code == 401:
            print("❌ Got 401 (Unauthorized) - токен недействителен или истек")
            return False
        elif response.status_code == 404:
            print("❌ Got 404 (Not Found) - квест не найден")
            return False
        elif response.status_code == 500:
            print("❌ Got 500 (Internal Server Error) - ошибка сервера")
            print(f"   Детали: {response.text}")
            return False
        else:
            print(f"⚠️  UNEXPECTED: Got {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Cannot connect to server")
        return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

async def check_quest_exists(quest_id):
    """Проверяем, существует ли квест"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    try:
        conn = await asyncpg.connect(database_url)
        quest = await conn.fetchrow("SELECT id, name FROM quest WHERE id = $1", quest_id)
        await conn.close()
        
        if quest:
            print(f"✅ Квест {quest_id} существует: {quest['name']}")
            return True
        else:
            print(f"❌ Квест {quest_id} не найден")
            return False
            
    except Exception as e:
        print(f"❌ Ошибка при проверке: {e}")
        return False

async def main():
    """Основная функция - удаляем квест до успеха"""
    
    print("🗑️  УДАЛЕНИЕ КВЕСТА С АВТОРИЗАЦИЕЙ ДО УСПЕХА")
    print("=" * 60)
    
    # Получаем токен админа
    token = get_admin_token()
    if not token:
        print("❌ Не удалось получить токен админа")
        return
    
    # Создаем тестовый квест
    quest_id = await create_test_quest()
    if not quest_id:
        print("❌ Не удалось создать тестовый квест")
        return
    
    # Проверяем, что квест создан
    if not await check_quest_exists(quest_id):
        print("❌ Тестовый квест не найден после создания")
        return
    
    # Пробуем удалить квест до успеха
    attempt = 1
    max_attempts = 5
    
    while attempt <= max_attempts:
        print(f"\n🎯 Попытка {attempt}/{max_attempts}: Удаляем квест {quest_id}...")
        
        success = test_delete_api_with_auth(quest_id, token)
        
        if success:
            print("🎉 УСПЕХ! Квест удален через API!")
            break
        
        # Проверяем, удален ли квест (возможно, удаление прошло, но ответ был неправильный)
        print(f"\n🔍 Проверяем, удален ли квест...")
        if not await check_quest_exists(quest_id):
            print("🎉 УСПЕХ! Квест удален (проверка через БД)")
            break
        
        print(f"❌ Попытка {attempt} неудачна, квест все еще существует")
        attempt += 1
        
        if attempt <= max_attempts:
            print(f"⏳ Ждем 2 секунды перед следующей попыткой...")
            time.sleep(2)
    
    if attempt > max_attempts:
        print("💥 Все попытки исчерпаны, квест не удален")
    
    # Финальная проверка
    print(f"\n🔍 Финальная проверка...")
    if not await check_quest_exists(quest_id):
        print("🎉 ФИНАЛЬНЫЙ УСПЕХ! Квест больше не существует")
    else:
        print("❌ НЕУДАЧА: Квест все еще существует")

if __name__ == "__main__":
    asyncio.run(main())
