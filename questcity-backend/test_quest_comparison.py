#!/usr/bin/env python3
"""
Скрипт для сравнения работы API для обычного пользователя и админа
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def get_testuser_token():
    """Получаем токен для testuser"""
    try:
        login_data = {
            "login": "testuser@questcity.com",
            "password": "password123"
        }
        
        response = requests.post(f"{BASE_URL}/api/v1/auth/login", data=login_data)
        if response.status_code == 200:
            result = response.json()
            return result.get("accessToken")
        else:
            print(f"❌ Ошибка логина testuser: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Ошибка при получении токена testuser: {e}")
        return None

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

def test_quest_comparison():
    """Сравниваем работу API для обычного пользователя и админа"""
    
    print("🧪 Сравнение работы API для обычного пользователя и админа")
    print("=" * 70)
    
    # Получаем токены
    testuser_token = get_testuser_token()
    admin_token = get_admin_token()
    
    if not testuser_token:
        print("❌ Не удалось получить токен testuser")
        return
    
    if not admin_token:
        print("❌ Не удалось получить токен admin")
        return
    
    print(f"✅ Токены получены:")
    print(f"   - testuser: {testuser_token[:20]}...")
    print(f"   - admin: {admin_token[:20]}...")
    print()
    
    # Тестируем эндпоинты
    endpoints_to_test = [
        {
            "name": "Получение всех квестов",
            "url": f"{BASE_URL}/api/v1/quests/",
            "method": "GET"
        },
        {
            "name": "Админский список квестов",
            "url": f"{BASE_URL}/api/v1/quests/admin/list",
            "method": "GET"
        },
        {
            "name": "Детали квеста",
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
        print()
        
        # Тест с обычным пользователем
        print(f"   👤 Обычный пользователь (testuser):")
        try:
            headers = {
                "Authorization": f"Bearer {testuser_token}",
                "Content-Type": "application/json"
            }
            
            if endpoint['method'] == 'GET':
                response = requests.get(endpoint['url'], headers=headers, timeout=10)
            else:
                response = requests.post(endpoint['url'], headers=headers, timeout=10)
            
            print(f"      Статус: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list):
                        print(f"      Результат: список из {len(data)} элементов")
                        if len(data) > 0:
                            print(f"      Первый элемент: {data[0].get('name', data[0].get('title', 'N/A'))}")
                    elif isinstance(data, dict):
                        print(f"      Результат: объект с ключами: {list(data.keys())}")
                        if 'name' in data or 'title' in data:
                            name = data.get('name', data.get('title', 'N/A'))
                            print(f"      Название квеста: {name}")
                except:
                    print(f"      Результат: {response.text[:50]}...")
            else:
                print(f"      Ошибка: {response.text}")
                
        except Exception as e:
            print(f"      ❌ Исключение: {e}")
        
        print()
        
        # Тест с админом
        print(f"   👑 Админ:")
        try:
            headers = {
                "Authorization": f"Bearer {admin_token}",
                "Content-Type": "application/json"
            }
            
            if endpoint['method'] == 'GET':
                response = requests.get(endpoint['url'], headers=headers, timeout=10)
            else:
                response = requests.post(endpoint['url'], headers=headers, timeout=10)
            
            print(f"      Статус: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list):
                        print(f"      Результат: список из {len(data)} элементов")
                        if len(data) > 0:
                            print(f"      Первый элемент: {data[0].get('name', data[0].get('title', 'N/A'))}")
                    elif isinstance(data, dict):
                        print(f"      Результат: объект с ключами: {list(data.keys())}")
                        if 'name' in data or 'title' in data:
                            name = data.get('name', data.get('title', 'N/A'))
                            print(f"      Название квеста: {name}")
                except:
                    print(f"      Результат: {response.text[:50]}...")
            else:
                print(f"      Ошибка: {response.text}")
                
        except Exception as e:
            print(f"      ❌ Исключение: {e}")
        
        print("-" * 70)
        print()

if __name__ == "__main__":
    test_quest_comparison()
