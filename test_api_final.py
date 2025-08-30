#!/usr/bin/env python3
"""
Финальное тестирование API после исправления базы данных
"""
import requests
import json

# Базовый URL API
BASE_URL = "http://questcity.ru/api/v1"

def test_api():
    """Тестирование API"""
    print("🧪 Финальное тестирование API после исправления базы данных")
    print("=" * 80)

    # Тест 1: Проверка доступности API
    print("\n📋 Тест 1: Проверка доступности API")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        print(f"  📡 Статус ответа: {response.status_code}")
        if response.status_code == 200:
            print("  ✅ API доступен")
        else:
            print(f"  ❌ API недоступен: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка подключения: {e}")

    # Тест 2: Авторизация админа
    print("\n📋 Тест 2: Авторизация админа")
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
                print(f"  🔑 Получен токен доступа")
                return access_token
            else:
                print("  ❌ Токен не найден в ответе")
                print(f"  📄 Ответ: {result}")
        else:
            print(f"  ❌ Ошибка авторизации: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
    
    return None

def test_quest_creation(access_token):
    """Тестирование создания квеста"""
    print("\n📋 Тест 3: Создание квеста")
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    quest_data = {
        "name": "Тестовый квест после исправления БД",
        "description": "Этот квест создан для тестирования после исправления структуры базы данных",
        "image_url": "https://example.com/test-quest.jpg",
        "type": "ADVENTURE",
        "is_active": True,
        "cost": 100,
        "reward": 500,
        "duration": 60,
        "group": "TWO",
        "place_id": 1,
        "has_guide": False,
        "mentor_preference": "",
        "timeframe": "ONE_HOUR",
        "level": "EASY",
        "mileage": "UP_TO_TEN",
        "category_id": 1,
        "vehicle_id": 1
    }
    
    try:
        response = requests.post(f"{BASE_URL}/quests/admin/create", json=quest_data, headers=headers, timeout=10)
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
    print("🧪 Финальное тестирование API после исправления базы данных")
    print("=" * 80)
    
    # Тестируем API
    access_token = test_api()
    
    # Если авторизация успешна, тестируем создание квеста
    if access_token:
        test_quest_creation(access_token)
    
    print("\n" + "=" * 80)
    print("✅ Тестирование завершено")

if __name__ == "__main__":
    main()
