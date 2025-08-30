#!/usr/bin/env python3
"""
Тестирование авторизации после восстановления из бэкапа
"""
import requests
import json

# URL для тестирования
BASE_URL = "https://questcity.ru/api/v1"

def test_auth():
    """Тестирует авторизацию"""
    print("🔧 ТЕСТИРОВАНИЕ АВТОРИЗАЦИИ ПОСЛЕ ВОССТАНОВЛЕНИЯ")
    print("=" * 80)
    
    # Тест 1: JSON авторизация
    print("\n📋 Тест 1: JSON авторизация")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            json={
                "login": "admin@questcity.com",
                "password": "admin123"
            },
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text[:500]}")
        
        if response.status_code == 200:
            print("  ✅ JSON авторизация успешна!")
        else:
            print("  ❌ JSON авторизация не удалась")
            
    except Exception as e:
        print(f"  ❌ Ошибка JSON авторизации: {e}")
    
    # Тест 2: Form-data авторизация
    print("\n📋 Тест 2: Form-data авторизация")
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
        
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text[:500]}")
        
        if response.status_code == 200:
            print("  ✅ Form-data авторизация успешна!")
        else:
            print("  ❌ Form-data авторизация не удалась")
            
    except Exception as e:
        print(f"  ❌ Ошибка Form-data авторизации: {e}")
    
    # Тест 3: Проверка здоровья API
    print("\n📋 Тест 3: Проверка здоровья API")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
        
        if response.status_code == 200:
            print("  ✅ API работает!")
        else:
            print("  ❌ API не отвечает")
            
    except Exception as e:
        print(f"  ❌ Ошибка проверки API: {e}")

if __name__ == "__main__":
    test_auth()
