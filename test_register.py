#!/usr/bin/env python3
"""
Тест регистрации
"""
import requests
import json

BASE_URL = "http://questcity.ru/api/v1"

def test_register():
    """Тест регистрации"""
    print("🧪 ТЕСТ РЕГИСТРАЦИИ")
    print("=" * 80)
    
    # Тест регистрации
    print("\n📋 Тест регистрации нового пользователя")
    register_data = {
        "email": "test@questcity.com",
        "username": "testuser",
        "password": "test123"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/register", json=register_data, timeout=10)
        print(f"  📡 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
        
        if response.status_code == 200 or response.status_code == 201:
            print("  ✅ Регистрация успешна!")
            return True
        else:
            print("  ❌ Регистрация не удалась")
    except Exception as e:
        print(f"  ❌ Ошибка запроса: {e}")
    
    return False

if __name__ == "__main__":
    test_register()
