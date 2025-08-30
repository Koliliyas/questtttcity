#!/usr/bin/env python3
"""
Тест регистрации с правильным паролем
"""
import requests
import json

BASE_URL = "http://questcity.ru/api/v1"

def test_register_final():
    """Тест регистрации с правильным паролем"""
    print("🧪 ТЕСТ РЕГИСТРАЦИИ С ПРАВИЛЬНЫМ ПАРОЛЕМ")
    print("=" * 80)
    
    # Тест регистрации с правильным паролем
    print("\n📋 Тест регистрации нового пользователя")
    register_data = {
        "email": "test3@questcity.com",
        "username": "testuser3",
        "password1": "test12345",
        "password2": "test12345",
        "firstName": "Test",
        "lastName": "User"
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
    test_register_final()
