#!/usr/bin/env python3
"""
Простой тест создания квеста
"""
import requests
import json

# URL для тестирования
BASE_URL = "http://questcity.ru/api/v1"

def test_simple_quest():
    """Простой тест создания квеста"""
    print("🔧 ПРОСТОЙ ТЕСТ СОЗДАНИЯ КВЕСТА")
    print("=" * 80)
    
    # 1. Авторизация
    print("\n📋 Авторизация...")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            data={
                "login": "admin@questcity.com",
                "password": "admin123"
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            token = data.get('accessToken')
            print(f"  ✅ Авторизация успешна, токен получен")
        else:
            print(f"  ❌ Авторизация не удалась: {response.status_code}")
            return
            
    except Exception as e:
        print(f"  ❌ Ошибка авторизации: {e}")
        return
    
    # 2. Создание квеста
    print("\n📋 Создание квеста...")
    try:
        quest_data = {
            "name": "Test Quest",
            "description": "Test Description",
            "category_id": 1,
            "vehicle_id": 1,
            "place_id": 1,
            "group": "test",
            "level": "easy",
            "mileage": 5
        }
        
        print(f"  📤 Данные: {json.dumps(quest_data, ensure_ascii=False)}")
        
        response = requests.post(
            f"{BASE_URL}/quests",
            json=quest_data,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {token}"
            },
            timeout=10
        )
        
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
        
        if response.status_code == 200:
            print("  ✅ Квест создан успешно!")
        else:
            print("  ❌ Создание квеста не удалось")
            
    except Exception as e:
        print(f"  ❌ Ошибка создания квеста: {e}")

if __name__ == "__main__":
    test_simple_quest()
