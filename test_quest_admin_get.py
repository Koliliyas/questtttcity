#!/usr/bin/env python3
"""
Тест GET запроса к /quests/admin
"""
import requests
import json

# URL для тестирования
BASE_URL = "http://questcity.ru/api/v1"

def test_quest_admin_get():
    """Тестирует GET запрос к /quests/admin"""
    print("🔧 ТЕСТ GET ЗАПРОСА К /QUESTS/ADMIN")
    print("=" * 80)
    
    # 1. Авторизация
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
    
    # 2. GET запрос к /quests/admin
    print("\n📋 GET запрос к /quests/admin...")
    try:
        response = requests.get(
            f"{BASE_URL}/quests/admin",
            headers={
                "Authorization": f"Bearer {token}"
            },
            timeout=10
        )
        
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text[:500]}...")
        
        if response.status_code == 200:
            print("  ✅ GET запрос успешен!")
        else:
            print("  ❌ GET запрос не удался")
            
    except Exception as e:
        print(f"  ❌ Ошибка GET запроса: {e}")

if __name__ == "__main__":
    test_quest_admin_get()
