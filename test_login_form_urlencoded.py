#!/usr/bin/env python3
"""
Тест авторизации с x-www-form-urlencoded
"""
import requests
import json

BASE_URL = "http://questcity.ru/api/v1"

def test_login_form_urlencoded():
    """Тест авторизации с x-www-form-urlencoded"""
    print("🧪 ТЕСТ АВТОРИЗАЦИИ С X-WWW-FORM-URLENCODED")
    print("=" * 80)
    
    # Тест с x-www-form-urlencoded
    print("\n📋 Тест с x-www-form-urlencoded")
    login_data = {
        "login": "admin@questcity.com",
        "password": "admin123"
    }
    
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/login", data=login_data, headers=headers, timeout=10)
        print(f"  📡 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
        
        if response.status_code == 200:
            print("  ✅ Авторизация успешна!")
            return True
        else:
            print("  ❌ Авторизация не удалась")
    except Exception as e:
        print(f"  ❌ Ошибка запроса: {e}")
    
    # Тест с multipart/form-data
    print("\n📋 Тест с multipart/form-data")
    try:
        response = requests.post(f"{BASE_URL}/auth/login", files=login_data, timeout=10)
        print(f"  📡 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
        
        if response.status_code == 200:
            print("  ✅ Авторизация успешна!")
            return True
        else:
            print("  ❌ Авторизация не удалась")
    except Exception as e:
        print(f"  ❌ Ошибка запроса: {e}")
    
    return False

if __name__ == "__main__":
    test_login_form_urlencoded()
