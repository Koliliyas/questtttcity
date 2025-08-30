#!/usr/bin/env python3
"""
Тест для создания квеста с базовыми точками без новых полей
"""

import requests
import json

BASE_URL = "http://localhost:8000"
CREATE_QUEST_URL = f"{BASE_URL}/api/v1/quests/create"

def get_admin_token():
    """Получаем токен администратора"""
    try:
        with open('.admin_token', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        print("❌ Файл .admin_token не найден!")
        return None

def test_quest_basic_points():
    """Тестируем создание квеста с базовыми точками"""
    
    token = get_admin_token()
    if not token:
        print("❌ Не удалось получить токен администратора")
        return
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # Данные квеста с базовыми точками (без новых полей)
    quest_data = {
        "name": "Квест с базовыми точками",
        "description": "Квест для тестирования с базовыми точками",
        "image": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=",
        "merch": [],
        "credits": {
            "cost": 100,
            "reward": 200
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
        "mentor_preference": "no_mentor",
        "points": [
            {
                "name_of_location": "Стартовая точка",
                "description": "Описание стартовой точки",
                "order": 0,
                "type_id": 1,
                "tool_id": None,
                "places": [
                    {
                        "longitude": 34.0522,
                        "latitude": -118.2437,
                        "detections_radius": 5.0,
                        "height": 1.8,
                        "interaction_inaccuracy": 5.0,
                        "part": 1,
                        "random_occurrence": None,
                        "random_occurrence_radius": None
                    }
                ],
                "file": None,
                "is_divide": False
                # Убираем новые поля: type_photo, type_code, type_word
            }
        ]
    }
    
    print("🚀 Отправляем запрос на создание квеста с базовыми точками...")
    
    try:
        response = requests.post(CREATE_QUEST_URL, headers=headers, json=quest_data)
        
        print(f"📡 Ответ сервера:")
        print(f"  - Status Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"  - Response: {json.dumps(result, indent=2, ensure_ascii=False)}")
            print("✅ Квест успешно создан!")
        else:
            print(f"❌ Ошибка создания квеста:")
            print(f"  - Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Исключение при создании квеста: {e}")

if __name__ == "__main__":
    test_quest_basic_points()
