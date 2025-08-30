#!/usr/bin/env python3
"""
Тест различных эндпоинтов API
"""
import requests
import json

# URL для тестирования
BASE_URL = "http://questcity.ru/api/v1"

def test_api_endpoints():
    """Тестирует различные эндпоинты API"""
    print("🔧 ТЕСТ РАЗЛИЧНЫХ ЭНДПОИНТОВ API")
    print("=" * 80)
    
    # 1. Проверка здоровья
    print("\n📋 Проверка здоровья API...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
    
    # 2. Авторизация
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
    
    # 3. Тест GET запроса с токеном
    print("\n📋 Тест GET запроса с токеном...")
    try:
        response = requests.get(
            f"{BASE_URL}/quests",
            headers={
                "Authorization": f"Bearer {token}"
            },
            timeout=10
        )
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text[:200]}...")
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
    
    # 4. Тест POST запроса с простыми данными
    print("\n📋 Тест POST запроса с простыми данными...")
    try:
        simple_data = {"test": "value"}
        response = requests.post(
            f"{BASE_URL}/quest/admin",
            json=simple_data,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {token}"
            },
            timeout=10
        )
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")

if __name__ == "__main__":
    test_api_endpoints()
