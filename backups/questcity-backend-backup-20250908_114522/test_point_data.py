#!/usr/bin/env python3
"""
Тестирование сохранения и получения данных точек квеста
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

async def create_test_quest_with_specific_data():
    """Создаем тестовый квест с конкретными type_id и tool_id"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🧪 Создаем тестовый квест с конкретными данными")
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
            f"Тестовый квест с данными {int(time.time())}",  # name
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
        
        # Создаем тестовую точку с конкретными type_id и tool_id
        point_query = """
        INSERT INTO point (name_of_location, description, "order", type_id, tool_id, 
                          file, is_divide, quest_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id
        """
        
        # Используем конкретные ID: type_id=4 (Scan Qr-code), tool_id=5 (Mile orbital radar)
        point_result = await conn.fetchrow(point_query,
            "Тестовая точка с данными",      # name_of_location
            "Описание тестовой точки",       # description
            1,                              # order
            4,                              # type_id (Scan Qr-code)
            5,                              # tool_id (Mile orbital radar)
            "test_file.txt",                # file
            False,                          # is_divide
            quest_id                        # quest_id
        )
        
        point_id = point_result['id']
        print(f"✅ Создана тестовая точка с ID: {point_id}")
        print(f"   - type_id: 4 (Scan Qr-code)")
        print(f"   - tool_id: 5 (Mile orbital radar)")
        
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
        
        await conn.close()
        return quest_id
        
    except Exception as e:
        print(f"❌ Ошибка при создании тестового квеста: {e}")
        return None

def test_get_quest_data(quest_id, token):
    """Тестируем получение данных квеста через API"""
    
    BASE_URL = "http://localhost:8000/api/v1"
    
    print(f"\n🌐 Тестируем получение данных квеста {quest_id} через API")
    print(f"📡 URL: {BASE_URL}/quests/admin/{quest_id}")
    print("=" * 60)
    
    try:
        # Заголовки с авторизацией
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        
        # Отправляем GET запрос с авторизацией
        response = requests.get(f"{BASE_URL}/quests/admin/{quest_id}", headers=headers)
        
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ SUCCESS: Данные квеста получены!")
            
            # Отладочная информация о полном ответе
            print(f"🔍 Полный ответ API:")
            print(f"   - Ключи в ответе: {list(data.keys())}")
            
            # Проверяем данные точек
            points = data.get('points', [])
            print(f"📋 Найдено точек: {len(points)}")
            
            for i, point in enumerate(points):
                print(f"\n🔍 Точка {i + 1}:")
                print(f"   - Полные данные точки: {point}")
                print(f"   - id: {point.get('id')}")
                print(f"   - name: {point.get('name')}")
                print(f"   - order: {point.get('order')}")
                print(f"   - type_id: {point.get('type_id')}")
                print(f"   - tool_id: {point.get('tool_id')}")
                print(f"   - places: {len(point.get('places', []))}")
            
            return True
        else:
            print(f"❌ Got {response.status_code}: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Cannot connect to server")
        return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

async def check_quest_in_database(quest_id):
    """Проверяем данные квеста в базе данных"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"\n🔍 Проверяем данные квеста {quest_id} в базе данных")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Проверяем квест
        quest = await conn.fetchrow("SELECT id, name FROM quest WHERE id = $1", quest_id)
        if quest:
            print(f"✅ Квест найден: {quest['name']}")
        else:
            print(f"❌ Квест {quest_id} не найден")
            await conn.close()
            return False
        
        # Проверяем точки квеста
        points = await conn.fetch("""
            SELECT id, name_of_location, "order", type_id, tool_id, description
            FROM point 
            WHERE quest_id = $1 
            ORDER BY "order"
        """, quest_id)
        
        print(f"📋 Найдено точек в БД: {len(points)}")
        
        for i, point in enumerate(points):
            print(f"\n🔍 Точка {i + 1} в БД:")
            print(f"   - id: {point['id']}")
            print(f"   - name_of_location: {point['name_of_location']}")
            print(f"   - order: {point['order']}")
            print(f"   - type_id: {point['type_id']}")
            print(f"   - tool_id: {point['tool_id']}")
            print(f"   - description: {point['description']}")
        
        await conn.close()
        return True
        
    except Exception as e:
        print(f"❌ Ошибка при проверке: {e}")
        return False

async def main():
    """Основная функция тестирования"""
    
    print("🧪 ТЕСТИРОВАНИЕ СОХРАНЕНИЯ И ПОЛУЧЕНИЯ ДАННЫХ ТОЧЕК КВЕСТА")
    print("=" * 60)
    
    # Получаем токен админа
    token = get_admin_token()
    if not token:
        print("❌ Не удалось получить токен админа")
        return
    
    # Создаем тестовый квест с конкретными данными
    quest_id = await create_test_quest_with_specific_data()
    if not quest_id:
        print("❌ Не удалось создать тестовый квест")
        return
    
    # Проверяем данные в базе данных
    if not await check_quest_in_database(quest_id):
        print("❌ Ошибка при проверке данных в БД")
        return
    
    # Тестируем получение данных через API
    if not test_get_quest_data(quest_id, token):
        print("❌ Ошибка при получении данных через API")
        return
    
    print("\n🎉 ТЕСТИРОВАНИЕ ЗАВЕРШЕНО УСПЕШНО!")

if __name__ == "__main__":
    asyncio.run(main())
