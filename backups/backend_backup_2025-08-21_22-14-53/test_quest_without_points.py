#!/usr/bin/env python3
"""
Тест для создания квеста без точек
"""

import requests
import json

BASE_URL = "http://localhost:8000"
CREATE_QUEST_URL = f"{BASE_URL}/api/v1/quests/admin/create"

def get_admin_token():
    """Получаем токен администратора"""
    try:
        with open('.admin_token', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        print("❌ Файл .admin_token не найден!")
        return None

def test_quest_without_points():
    """Тестируем создание квеста без точек"""
    
    token = get_admin_token()
    if not token:
        print("❌ Не удалось получить токен администратора")
        return
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # Данные квеста без точек
    quest_data = {
        "name": "Квест без точек",
        "description": "Квест для тестирования без точек",
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
        "points": []  # Пустой массив точек
    }
    
    print("🚀 Отправляем запрос на создание квеста без точек...")
    
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
    test_quest_without_points()


