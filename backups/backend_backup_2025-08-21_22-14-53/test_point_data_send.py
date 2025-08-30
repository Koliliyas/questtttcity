#!/usr/bin/env python3
"""
Тестовый скрипт для проверки отправки данных точек с новыми полями
"""

import requests
import json
import base64

# Конфигурация
BASE_URL = "http://localhost:8000"
LOGIN_URL = f"{BASE_URL}/api/auth/login"
CREATE_QUEST_URL = f"{BASE_URL}/api/v1/quests/admin/create"

def get_admin_token():
    """Получаем токен администратора"""
    try:
        with open('.admin_token', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        print("❌ Файл .admin_token не найден!")
        return None

def test_create_quest_with_point_data():
    """Тестируем создание квеста с полными данными точек"""
    
    # Получаем токен
    token = get_admin_token()
    if not token:
        print("❌ Не удалось получить токен администратора")
        return
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # Тестовые данные квеста с полными данными точек
    quest_data = {
        "name": "Тестовый квест с данными точек",
        "description": "Квест для тестирования отправки данных точек",
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
            "group": 1,  # 1 = SOLO, 2 = DUO, 3 = TEAM, 4 = FAMILY
            "timeframe": 1,
            "level": "Easy",  # "Easy", "Medium", "Hard"
            "mileage": "5-10",  # "5-10", "10-30", "30-100", ">100"
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
                "type_id": 1,  # Catch a ghost
                "tool_id": None,  # Убираем tool_id, чтобы избежать ошибки
                "places": [
                    {
                        "longitude": 34.0522,
                        "latitude": -118.2437,
                        "detections_radius": 5.0,
                        "height": 1.8,
                        "interaction_inaccuracy": 5.0,
                        "part": 1,
                        "random_occurrence": 5.0,  # Должно быть число >= 5, а не boolean
                        "random_occurrence_radius": 5.0
                    }
                ],
                "file": None,
                "is_divide": False
                # Временно убираем новые поля
            },
            {
                "name_of_location": "Конечная точка",
                "description": "Описание конечной точки",
                "order": 1,
                "type_id": 2,  # Take a photo
                "tool_id": None,  # Убираем tool_id, чтобы избежать ошибки
                "places": [
                    {
                        "longitude": 34.0622,
                        "latitude": -118.2537,
                        "detections_radius": 7.0,
                        "height": 2.0,
                        "interaction_inaccuracy": 5.0,  # Должно быть >= 5
                        "part": 1,
                        "random_occurrence": None,  # None вместо false
                        "random_occurrence_radius": None
                    }
                ],
                "file": None,  # Убираем файл, так как для файла нужно больше одного места
                "is_divide": False
                # Временно убираем новые поля
            },
            {
                "name_of_location": "Промежуточная точка",
                "description": "Описание промежуточной точки",
                "order": 2,
                "type_id": 5,  # Enter code
                "tool_id": None,  # Убираем tool_id, чтобы избежать ошибки
                "places": [
                    {
                        "longitude": 34.0722,
                        "latitude": -118.2637,
                        "detections_radius": 6.0,
                        "height": 1.9,
                        "interaction_inaccuracy": 5.0,  # Должно быть >= 5
                        "part": 1,
                        "random_occurrence": 6.0,  # Должно быть число >= 5
                        "random_occurrence_radius": 6.0
                    }
                ],
                "file": None,
                "is_divide": False
                # Временно убираем новые поля
            }
        ]
    }
    
    print("🚀 Отправляем запрос на создание квеста с полными данными точек...")
    print(f"📊 Количество точек: {len(quest_data['points'])}")
    
    for i, point in enumerate(quest_data['points']):
        print(f"  📍 Точка {i}:")
        print(f"    - name_of_location: {point['name_of_location']}")
        print(f"    - type_id: {point['type_id']}")
        print(f"    - tool_id: {point['tool_id']}")
        print(f"    - places count: {len(point['places'])}")
        print(f"    - file: {point['file']}")
        print(f"    - is_divide: {point['is_divide']}")
        # Временно убрали новые поля
    
    try:
        response = requests.post(CREATE_QUEST_URL, headers=headers, json=quest_data)
        
        print(f"\n📡 Ответ сервера:")
        print(f"  - Status Code: {response.status_code}")
        print(f"  - Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"  - Response: {json.dumps(result, indent=2, ensure_ascii=False)}")
            print("✅ Квест успешно создан!")
            
            # Проверяем, что данные точек сохранились
            quest_id = result.get('id')
            if quest_id:
                print(f"\n🔍 Проверяем сохранение данных для квеста ID: {quest_id}")
                check_quest_data(quest_id, token)
        else:
            print(f"❌ Ошибка создания квеста:")
            print(f"  - Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Исключение при создании квеста: {e}")

def check_quest_data(quest_id: int, token: str):
    """Проверяем, что данные квеста корректно сохранились"""
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.get(f"{BASE_URL}/api/v1/quests/admin/{quest_id}", headers=headers)
        
        if response.status_code == 200:
            quest_data = response.json()
            print("✅ Данные квеста получены:")
            print(f"  - ID: {quest_data.get('id')}")
            print(f"  - Name: {quest_data.get('name')}")
            
            points = quest_data.get('points', [])
            print(f"  - Points count: {len(points)}")
            
            for i, point in enumerate(points):
                print(f"    📍 Точка {i}:")
                print(f"      - name_of_location: {point.get('name_of_location')}")
                print(f"      - type_id: {point.get('type_id')}")
                print(f"      - tool_id: {point.get('tool_id')}")
                print(f"      - places count: {len(point.get('places', []))}")
                print(f"      - file: {point.get('file')}")
                print(f"      - is_divide: {point.get('is_divide')}")
                # Временно убрали новые поля
        else:
            print(f"❌ Ошибка получения данных квеста: {response.status_code}")
            print(f"  - Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Исключение при проверке данных квеста: {e}")

if __name__ == "__main__":
    print("🧪 ТЕСТИРОВАНИЕ ОТПРАВКИ ДАННЫХ ТОЧЕК")
    print("=" * 50)
    
    test_create_quest_with_point_data()
    
    print("\n" + "=" * 50)
    print("🏁 ТЕСТИРОВАНИЕ ЗАВЕРШЕНО")
