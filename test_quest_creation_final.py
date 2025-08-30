#!/usr/bin/env python3
"""
Финальный тест создания квеста через API после исправления базы данных
"""
import requests
import json
from datetime import datetime

# URL API
BASE_URL = "http://questcity.ru/api/v1"

def test_quest_creation():
    """Тестирует создание квеста через API"""
    print("🧪 Финальный тест создания квеста через API")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Сначала получаем токен авторизации
    print("🔐 Получение токена авторизации...")
    login_data = {
        'login': 'admin@questcity.com',
        'password': 'admin123'
    }
    
    try:
        login_response = requests.post(f"{BASE_URL}/auth/login", data=login_data)
        print(f"📡 Статус ответа: {login_response.status_code}")
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            access_token = login_result.get('accessToken')
            print("✅ Авторизация успешна!")
            print(f"🔑 Токен получен: {access_token[:20]}...")
        else:
            print(f"❌ Ошибка авторизации: {login_response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Ошибка при авторизации: {e}")
        return False

    # Тестируем создание квеста через /quests/admin/create
    print("\n📝 Тестирование создания квеста через /quests/admin/create...")
    
    quest_data = {
        "name": "Тестовый квест после исправления БД",
        "description": "Этот квест создан для тестирования после исправления структуры базы данных",
        "image_url": "https://example.com/test-quest.jpg",
        "type": "ADVENTURE",
        "is_active": True,
        "cost": 100,
        "reward": 500,
        "duration": 60,
        "group_size": "TWO",
        "place_id": 1,
        "has_guide": False,
        "mentor_preference": "",
        "timeframe": "ONE_HOUR",
        "level": "EASY",
        "mileage": "UP_TO_TEN",
        "category_id": 1,
        "points": [
            {
                "name_of_location": "Стартовая точка",
                "order": 1,
                "description": "Начало квеста",
                "type_id": 1,
                "tool_id": None,
                "is_divide": False
            },
            {
                "name_of_location": "Промежуточная точка",
                "order": 2,
                "description": "Средняя точка квеста",
                "type_id": 2,
                "tool_id": 1,
                "is_divide": False
            }
        ]
    }

    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }

    try:
        response = requests.post(
            f"{BASE_URL}/quests/admin/create",
            json=quest_data,
            headers=headers
        )
        
        print(f"📡 Статус ответа: {response.status_code}")
        print(f"📄 Заголовки ответа: {dict(response.headers)}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Квест успешно создан!")
            print(f"📋 Результат: {json.dumps(result, indent=2, ensure_ascii=False)}")
            return True
        else:
            print(f"❌ Ошибка создания квеста: {response.status_code}")
            print(f"📄 Ответ: {response.text}")
            
            # Пробуем получить более подробную информацию об ошибке
            try:
                error_data = response.json()
                print(f"🔍 Детали ошибки: {json.dumps(error_data, indent=2, ensure_ascii=False)}")
            except:
                print("🔍 Не удалось разобрать JSON ответ")
            
            return False
            
    except Exception as e:
        print(f"❌ Ошибка при создании квеста: {e}")
        return False

def test_simple_quest_creation():
    """Тестирует создание простого квеста без точек"""
    print("\n📝 Тестирование создания простого квеста без точек...")
    
    # Получаем токен
    login_data = {
        'login': 'admin@questcity.com',
        'password': 'admin123'
    }
    
    try:
        login_response = requests.post(f"{BASE_URL}/auth/login", data=login_data)
        if login_response.status_code == 200:
            access_token = login_response.json().get('accessToken')
        else:
            print("❌ Не удалось получить токен для простого теста")
            return False
    except Exception as e:
        print(f"❌ Ошибка при получении токена: {e}")
        return False

    # Простой квест без точек
    simple_quest_data = {
        "name": "Простой тестовый квест",
        "description": "Простой квест без точек для тестирования",
        "image_url": "https://example.com/simple-quest.jpg",
        "type": "ADVENTURE",
        "is_active": True,
        "cost": 50,
        "reward": 200,
        "duration": 30,
        "group_size": "TWO",
        "place_id": 1,
        "has_guide": False,
        "mentor_preference": "",
        "timeframe": "ONE_HOUR",
        "level": "EASY",
        "mileage": "UP_TO_TEN",
        "category_id": 1
    }

    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }

    try:
        response = requests.post(
            f"{BASE_URL}/quests/admin/create",
            json=simple_quest_data,
            headers=headers
        )
        
        print(f"📡 Статус ответа: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Простой квест успешно создан!")
            print(f"📋 Результат: {json.dumps(result, indent=2, ensure_ascii=False)}")
            return True
        else:
            print(f"❌ Ошибка создания простого квеста: {response.status_code}")
            print(f"📄 Ответ: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Ошибка при создании простого квеста: {e}")
        return False

def main():
    print("🧪 Финальное тестирование создания квестов")
    print("=" * 80)
    
    # Тест 1: Создание квеста с точками
    success1 = test_quest_creation()
    
    # Тест 2: Создание простого квеста без точек
    success2 = test_simple_quest_creation()
    
    print(f"\n{'='*80}")
    if success1 and success2:
        print("🎉 Все тесты прошли успешно!")
        print("✅ Создание квестов работает корректно")
        print("✅ База данных исправлена и функционирует")
    elif success2:
        print("⚠️ Частичный успех")
        print("✅ Простые квесты создаются успешно")
        print("❌ Квесты с точками требуют дополнительной настройки")
    else:
        print("❌ Тесты не прошли")
        print("🔧 Требуется дополнительная диагностика")

if __name__ == "__main__":
    main()
