#!/usr/bin/env python3
"""
Тестирование авторизации через form-data
"""
import requests
import json

# URL для тестирования
BASE_URL = "http://questcity.ru/api/v1"

def test_auth_form_data():
    """Тестирует авторизацию через form-data"""
    print("🔧 ТЕСТИРОВАНИЕ АВТОРИЗАЦИИ ЧЕРЕЗ FORM-DATA")
    print("=" * 80)
    
    # Тест form-data авторизация
    print("\n📋 Тест form-data авторизация")
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
            # Сохраняем токен
            try:
                data = response.json()
                if 'accessToken' in data:
                    print(f"  🔑 Токен получен: {data['accessToken'][:50]}...")
                    return data['accessToken']
            except:
                pass
        else:
            print("  ❌ Form-data авторизация не удалась")
            
    except Exception as e:
        print(f"  ❌ Ошибка form-data авторизации: {e}")
    
    return None

def test_quest_creation(token):
    """Тестирует создание квеста"""
    if not token:
        print("\n❌ Нет токена для тестирования создания квеста")
        return
    
    print("\n📋 Тест создания квеста")
    try:
        quest_data = {
            "title": "Тестовый квест",
            "description": "Описание тестового квеста"
        }
        
        print(f"  📤 Отправляем данные: {quest_data}")
        
        response = requests.post(
            f"{BASE_URL}/quest/admin",
            json=quest_data,
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
    token = test_auth_form_data()
    test_quest_creation(token)
