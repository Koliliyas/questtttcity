#!/usr/bin/env python3
"""
Упрощенный скрипт для тестирования API эндпоинтов получения квестов
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def get_admin_token():
    """Получаем токен из файла .admin_token"""
    try:
        with open('.admin_token', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        print("❌ Файл .admin_token не найден!")
        return None
    except Exception as e:
        print(f"❌ Ошибка при чтении токена: {e}")
        return None

def test_quest_endpoints():
    """Тестируем различные эндпоинты получения квестов"""
    
    print("🧪 Тестирование API эндпоинтов получения квестов")
    print("=" * 60)
    
    # Получаем токен админа
    admin_token = get_admin_token()
    
    if not admin_token:
        print("❌ Не удалось получить токен админа")
        return
    
    print(f"✅ Токен админа получен: {admin_token[:20]}...")
    print()
    
    # Тестируем эндпоинты
    endpoints_to_test = [
        {
            "name": "Получение всех квестов (админ)",
            "url": f"{BASE_URL}/api/v1/quests/",
            "method": "GET"
        },
        {
            "name": "Админский список квестов",
            "url": f"{BASE_URL}/api/v1/quests/admin/list",
            "method": "GET"
        },
        {
            "name": "Детали квеста (админ)",
            "url": f"{BASE_URL}/api/v1/quests/3",
            "method": "GET"
        },
        {
            "name": "Админские детали квеста",
            "url": f"{BASE_URL}/api/v1/quests/admin/3",
            "method": "GET"
        },
        {
            "name": "Простой эндпоинт квеста",
            "url": f"{BASE_URL}/api/v1/quests/get-quest/3",
            "method": "GET"
        }
    ]
    
    for endpoint in endpoints_to_test:
        print(f"🔍 Тестируем: {endpoint['name']}")
        print(f"   URL: {endpoint['url']}")
        
        try:
            headers = {
                "Authorization": f"Bearer {admin_token}",
                "Content-Type": "application/json"
            }
            
            if endpoint['method'] == 'GET':
                response = requests.get(endpoint['url'], headers=headers, timeout=10)
            else:
                response = requests.post(endpoint['url'], headers=headers, timeout=10)
            
            print(f"   Статус: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list):
                        print(f"   Результат: список из {len(data)} элементов")
                        if len(data) > 0:
                            print(f"   Первый элемент: {data[0].get('name', 'N/A') if isinstance(data[0], dict) else str(data[0])[:50]}")
                    elif isinstance(data, dict):
                        print(f"   Результат: объект с ключами: {list(data.keys())}")
                        if 'name' in data:
                            print(f"   Название квеста: {data['name']}")
                except:
                    print(f"   Результат: {response.text[:100]}...")
            else:
                print(f"   Ошибка: {response.text}")
                
        except Exception as e:
            print(f"   ❌ Исключение: {e}")
        
        print()

if __name__ == "__main__":
    test_quest_endpoints()
