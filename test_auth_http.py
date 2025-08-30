#!/usr/bin/env python3
"""
Тестирование авторизации через HTTP
"""
import requests
import json

# URL для тестирования
BASE_URL = "http://questcity.ru/api/v1"

def test_auth():
    """Тестирует авторизацию"""
    print("🔧 ТЕСТИРОВАНИЕ АВТОРИЗАЦИИ ЧЕРЕЗ HTTP")
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
            # Сохраняем токен
            try:
                data = response.json()
                if 'access_token' in data:
                    print(f"  🔑 Токен получен: {data['access_token'][:50]}...")
                    return data['access_token']
            except:
                pass
        else:
            print("  ❌ JSON авторизация не удалась")
            
    except Exception as e:
        print(f"  ❌ Ошибка JSON авторизации: {e}")
    
    return None

def test_quest_creation(token):
    """Тестирует создание квеста"""
    if not token:
        print("\n❌ Нет токена для тестирования создания квеста")
        return
    
    print("\n📋 Тест создания квеста")
    try:
        response = requests.post(
            f"{BASE_URL}/quests/admin/create",
            json={
                "title": "Тестовый квест",
                "description": "Описание тестового квеста",
                "category_id": 1,
                "difficulty": "easy",
                "duration": 60,
                "max_participants": 4,
                "price": 1000,
                "location": "Москва",
                "coordinates": {"lat": 55.7558, "lng": 37.6176}
            },
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {token}"
            },
            timeout=10
        )
        
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text[:500]}")
        
        if response.status_code == 200:
            print("  ✅ Создание квеста успешно!")
        else:
            print("  ❌ Создание квеста не удалось")
            
    except Exception as e:
        print(f"  ❌ Ошибка создания квеста: {e}")

if __name__ == "__main__":
    token = test_auth()
    test_quest_creation(token)
