#!/usr/bin/env python3
"""
Тест авторизации с правильными данными
"""
import requests
import json

BASE_URL = "http://questcity.ru/api/v1"

def test_login_correct():
    """Тест авторизации с правильными данными"""
    print("🧪 ТЕСТ АВТОРИЗАЦИИ С ПРАВИЛЬНЫМИ ДАННЫМИ")
    print("=" * 80)
    
    # Тест с JSON
    print("\n📋 Тест авторизации с JSON...")
    login_data = {
        "login": "admin@questcity.com",
        "password": "admin123"
    }
    
    try:
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
    test_login_correct()
