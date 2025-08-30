#!/usr/bin/env python3
"""
Тестирование простого endpoint создания квеста
"""
import requests
import json

# Базовый URL API
BASE_URL = "http://questcity.ru/api/v1"

def test_simple_create_endpoint():
    """Тестирование простого endpoint создания квеста"""
    print("🧪 Тестирование простого endpoint создания квеста")
    print("=" * 80)

    # Авторизация админа
    print("\n📋 Авторизация админа")
    login_data = {
        "login": "admin@questcity.com",
        "password": "admin123"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/login", data=login_data, timeout=10)
        print(f"  📡 Статус ответа: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            access_token = result.get('accessToken')
            if access_token:
                print("  ✅ Авторизация успешна")
            else:
                print("  ❌ Токен не найден в ответе")
                return
        else:
            print(f"  ❌ Ошибка авторизации: {response.text}")
            return
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        return

    # Создание квеста через простой endpoint
    print("\n📋 Создание квеста через простой endpoint")
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    # Простая структура данных для /quests/create
    quest_data = {
        "name": "Простой квест",
        "description": "Описание простого квеста",
        "image": "https://example.com/image.jpg",
        "credits": {
            "auto": False,
            "cost": 100,
            "reward": 500
        },
        "main_preferences": {
            "category_id": 1,
            "vehicle_id": 1,
            "place_id": 1,
            "group": 2,
            "timeframe": 1,
            "level": "Easy",
            "mileage": "5-10",
            "types": [],
            "places": [],
            "vehicles": [],
            "tools": []
        },
        "mentor_preference": "",
        "merch": [],
        "points": []
    }
    
    print(f"  📄 Отправляемые данные:")
    print(json.dumps(quest_data, indent=2, ensure_ascii=False))
    
    try:
        response = requests.post(f"{BASE_URL}/quests/create", json=quest_data, headers=headers, timeout=10)
        print(f"  📡 Статус ответа: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("  ✅ Квест создан успешно")
            print(f"  📄 Ответ: {result}")
        else:
            print(f"  ❌ Ошибка создания квеста: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")

def main():
    test_simple_create_endpoint()
    print("\n" + "=" * 80)
    print("✅ Тестирование завершено")

if __name__ == "__main__":
    main()
