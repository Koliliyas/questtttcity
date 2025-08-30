#!/usr/bin/env python3
"""
Простой тест API для проверки доступности endpoints
"""
import requests
import json

BASE_URL = "http://questcity.ru/api/v1"

def test_api_endpoints():
    """Тестирование API endpoints"""
    print("🧪 ПРОСТОЙ ТЕСТ API ENDPOINTS")
    print("=" * 80)
    
    # Тест health check
    print("\n📋 Тест health check...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        print(f"  📡 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
    
    # Тест авторизации с правильными полями
    print("\n📋 Тест авторизации...")
    try:
        login_data = {
            "login": "admin@questcity.com",
            "password": "admin123"
        }
        
        response = requests.post(f"{BASE_URL}/auth/login", json=login_data, timeout=10)
        print(f"  📡 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
        
        if response.status_code == 200:
            print("  ✅ Авторизация успешна!")
        else:
            print("  ❌ Авторизация не удалась")
            
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
    
    # Тест с form-data
    print("\n📋 Тест авторизации с form-data...")
    try:
        login_data = {
            "login": "admin@questcity.com",
            "password": "admin123"
        }
        
        response = requests.post(f"{BASE_URL}/auth/login", data=login_data, timeout=10)
        print(f"  📡 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
        
        if response.status_code == 200:
            print("  ✅ Авторизация успешна!")
        else:
            print("  ❌ Авторизация не удалась")
            
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")

if __name__ == "__main__":
    test_api_endpoints()
