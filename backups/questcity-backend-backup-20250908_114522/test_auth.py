#!/usr/bin/env python3
"""
Простой тест авторизации QuestCity Backend
"""
import requests
import json
import sys

BASE_URL = "http://localhost:8000/api/v1"

def test_health():
    """Проверка health endpoint"""
    try:
        response = requests.get(f"{BASE_URL}/health/", timeout=5)
        print(f"✅ Health check: {response.status_code}")
        print(f"   Response: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False

def test_register():
    """Тест регистрации"""
    user_data = {
        "email": "testuser2@test.com",
        "username": "testuser2",
        "password1": "TestPass123!",
        "password2": "TestPass123!",
        "firstName": "Test",
        "lastName": "User2"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/auth/register", 
            json=user_data,
            timeout=10
        )
        print(f"✅ Register: {response.status_code}")
        if response.status_code != 204:
            print(f"   Response: {response.text}")
        return True
    except Exception as e:
        print(f"❌ Register failed: {e}")
        return False

def test_login():
    """Тест авторизации"""
    login_data = {
        "login": "testuser2",  # API ожидает "login" а не "username"
        "password": "TestPass123!"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            data=login_data,  # form data
            timeout=10
        )
        print(f"✅ Login: {response.status_code}")
        if response.status_code == 200:
            tokens = response.json()
            print(f"   Access token получен: {tokens.get('access_token', 'N/A')[:20]}...")
            return True
        else:
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Login failed: {e}")
        return False

def main():
    print("🚀 Тестирование QuestCity Backend Authorization")
    print("=" * 50)
    
    # Тестируем по порядку
    if not test_health():
        print("❌ Backend недоступен!")
        sys.exit(1)
    
    print()
    test_register()
    
    print()
    test_login()
    
    print("\n✅ Тестирование завершено!")

if __name__ == "__main__":
    main() 