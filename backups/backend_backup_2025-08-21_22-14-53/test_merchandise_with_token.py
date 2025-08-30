#!/usr/bin/env python3
"""
Скрипт для тестирования создания квеста с merchandise данными
"""

import asyncio
import os
import sys
import requests
import json

# Добавляем путь к модулям проекта
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

async def test_create_quest_with_merch():
    """Тестируем создание квеста с merchandise данными"""
    
    # Базовый URL API
    base_url = "http://localhost:8000/api/v1"
    
    print("🧪 Тестирование создания квеста с merchandise данными")
    print(f"📡 API URL: {base_url}")
    
    try:
        # 1. Читаем токен из файла
        print("\n🔐 Читаем токен из файла...")
        with open('.admin_token', 'r') as f:
            access_token = f.read().strip()
        
        print(f"✅ Токен получен: {access_token[:50]}...")
        
        # 2. Создаем квест с merchandise данными
        print("\n📝 Создаем квест с merchandise данными...")
        
        quest_data = {
            "name": "Test Quest with Merch",
            "description": "Тестовый квест с merchandise данными",
            "image": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==",
            "merch": [
                {
                    "description": "Тестовый мерч",
                    "price": 1000,
                    "image": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
                }
            ],
            "credits": {
                "cost": 0,
                "reward": 100
            },
            "main_preferences": {
                "category_id": 1,
                "vehicle_id": 1,
                "place_id": 1,
                "group": 1,
                "timeframe": 1,
                "level": "Easy",
                "mileage": "5-10",
                "types": [],
                "places": [],
                "vehicles": [1],
                "tools": []
            },
            "mentor_preference": "mentor_required",
            "points": [
                {
                    "name_of_location": "Start Point",
                    "description": "Начальная точка",
                    "order": 0,
                    "type_id": 1,
                    "places": [],
                    "tool_id": None,
                    "file": None,
                    "is_divide": False
                },
                {
                    "name_of_location": "Finish Point",
                    "description": "Конечная точка",
                    "order": 1,
                    "type_id": 1,
                    "places": [],
                    "tool_id": None,
                    "file": None,
                    "is_divide": False
                }
            ]
        }
        
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }
        
        create_response = requests.post(f"{base_url}/quests/admin/create", json=quest_data, headers=headers)
        print(f"📊 Статус создания квеста: {create_response.status_code}")
        
        if create_response.status_code == 201:
            quest_result = create_response.json()
            quest_id = quest_result.get("id")
            print(f"✅ Квест создан успешно! ID: {quest_id}")
            
            # 3. Получаем созданный квест для проверки
            print(f"\n🔍 Получаем созданный квест (ID: {quest_id})...")
            get_response = requests.get(f"{base_url}/quests/admin/{quest_id}", headers=headers)
            
            if get_response.status_code == 200:
                quest_data = get_response.json()
                print(f"✅ Квест получен успешно!")
                print(f"📊 Данные квеста:")
                print(f"  - ID: {quest_data.get('id')}")
                print(f"  - Name: {quest_data.get('title')}")
                print(f"  - Mentor Preference: {quest_data.get('mentorPreference')}")
                print(f"  - Merch List Length: {len(quest_data.get('merchList', []))}")
                
                if quest_data.get('merchList'):
                    merch = quest_data['merchList'][0]
                    print(f"  - Merch Description: {merch.get('description')}")
                    print(f"  - Merch Price: {merch.get('price')}")
                    print(f"  - Merch Image: {merch.get('image', '')[:50]}...")
                else:
                    print(f"  - Merch List: ПУСТОЙ!")
                    
                # Выводим полный JSON для анализа
                print(f"\n📄 Полный JSON ответ:")
                print(json.dumps(quest_data, indent=2, ensure_ascii=False))
            else:
                print(f"❌ Ошибка получения квеста: {get_response.status_code} - {get_response.text}")
        else:
            print(f"❌ Ошибка создания квеста: {create_response.status_code}")
            print(f"📄 Ответ: {create_response.text}")
            
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_create_quest_with_merch())


