#!/usr/bin/env python3
"""
Тестирование правильного endpoint /quests/admin/create
"""
import requests
import json

BASE_URL = "http://questcity.ru/api/v1"

def test_correct_endpoint():
    """Тестирование правильного endpoint"""
    print("🧪 Тестирование правильного endpoint /quests/admin/create")
    print("=" * 80)
    
    # Авторизация админа
    print("\n📋 Авторизация админа")
    try:
        login_data = {
            "login": "admin@questcity.com",
            "password": "admin123"
        }
        
        response = requests.post(f"{BASE_URL}/auth/login", data=login_data, timeout=10)
        print(f"  📡 Статус ответа: {response.status_code}")
        
        if response.status_code == 200:
            print("  ✅ Авторизация успешна!")
            token_data = response.json()
            access_token = token_data.get("access_token")
            
            if access_token:
                headers = {"Authorization": f"Bearer {access_token}"}
                
                # Создание квеста
                print("\n📋 Создание квеста")
                quest_data = {
                    "name": "Тестовый квест",
                    "description": "Описание тестового квеста",
                    "category_id": 1,
                    "vehicle_id": 1,
                    "tool_id": 1,
                    "place_id": 1,
                    "activity_id": 1,
                    "credits": {
                        "amount": 100,
                        "currency": "USD"
                    },
                    "main_preferences": {
                        "group": 1,
                        "timeframe": 1,
                        "level": "EASY",
                        "mileage": "SHORT"
                    },
                    "points": []
                }
                
                response = requests.post(f"{BASE_URL}/quests/admin/create", json=quest_data, headers=headers, timeout=10)
                print(f"  📡 Статус ответа: {response.status_code}")
                print(f"  📄 Ответ: {response.text}")
                
                if response.status_code == 200:
                    print("  ✅ Квест успешно создан!")
                else:
                    print("  ❌ Ошибка создания квеста")
            else:
                print("  ❌ Токен не найден в ответе")
        else:
            print(f"  ❌ Ошибка авторизации: {response.text}")
            
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
    
    print("\n" + "=" * 80)
    print("✅ Тестирование завершено")

if __name__ == "__main__":
    test_correct_endpoint()
