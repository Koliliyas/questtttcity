#!/usr/bin/env python3
"""
Простой тест создания квеста с минимальными данными
"""
import requests
import json
from datetime import datetime

def test_simple_quest_creation(base_url="http://questcity.ru/api/v1/"):
    """Тест создания квеста с минимальными данными"""
    print(f"🎯 Простой тест создания квеста")
    print("=" * 50)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 API URL: {base_url}")
    print()

    # Получаем токен администратора
    print("🔐 Получение токена администратора...")
    login_data = {
        "login": "admin@questcity.com",
        "password": "Admin123!"
    }

    try:
        login_response = requests.post(
            f"{base_url}auth/login",
            data=login_data,
            timeout=10,
            headers={"Accept": "application/json"}
        )

        if login_response.status_code != 200:
            print(f"❌ Ошибка входа: {login_response.status_code}")
            return False

        login_result = login_response.json()
        if "accessToken" not in login_result:
            print("❌ Токен не найден")
            return False

        access_token = login_result["accessToken"]
        print(f"✅ Токен получен: {access_token[:20]}...")

        # Минимальные данные для создания квеста
        quest_data = {
            "name": "Простой тестовый квест",
            "description": "Описание простого тестового квеста",
            "image": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=",
            "credits": {
                "cost": 0,
                "reward": 50
            },
            "main_preferences": {
                "level": "Easy",
                "mileage": "5-10",
                "category_id": 1,
                "vehicle_id": 1,
                "place_id": 1,
                "group": 2,
                "timeframe": 1
            },
            "mentor_preference": "",
            "merch": [],
            "points": [
                {
                    "name_of_location": "Тестовая точка",
                    "description": "Описание тестовой точки",
                    "order": 1,
                    "type_id": 1,
                    "places": [
                        {
                            "longitude": 37.6173,
                            "latitude": 55.7558,
                            "detections_radius": 5,
                            "height": 0,
                            "interaction_inaccuracy": 5,
                            "part": 1,
                            "random_occurrence": 5
                        }
                    ],
                    "tool_id": None,
                    "file": None,
                    "is_divide": False
                }
            ]
        }

        print("\n📝 Отправка минимальных данных для создания квеста...")
        print(f"📊 Данные: {json.dumps(quest_data, indent=2, ensure_ascii=False)}")

        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }

        # Тестируем только endpoint /create
        print(f"\n🔗 Тестирование endpoint: quests/create")
        
        response = requests.post(
            f"{base_url}quests/create",
            json=quest_data,
            headers=headers,
            timeout=30
        )

        print(f"📡 HTTP статус: {response.status_code}")
        print(f"📄 Заголовки ответа: {dict(response.headers)}")
        
        if response.status_code in [200, 201]:
            print("✅ Квест создан успешно!")
            result = response.json()
            print(f"📊 Ответ API:")
            print(json.dumps(result, indent=2, ensure_ascii=False))
            return True
            
        elif response.status_code == 422:
            print("❌ Ошибка валидации данных")
            print(f"📄 Ответ: {response.text}")
            
        elif response.status_code == 401:
            print("❌ Ошибка авторизации")
            print(f"📄 Ответ: {response.text}")
            
        elif response.status_code == 403:
            print("❌ Недостаточно прав")
            print(f"📄 Ответ: {response.text}")
            
        else:
            print(f"❌ Ошибка: {response.status_code}")
            print(f"📄 Ответ: {response.text}")

        return False

    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка подключения: {e}")
        return False

def main():
    print("🧪 Простой тест создания квеста QuestCity")
    print("=" * 50)
    
    success = test_simple_quest_creation()
    
    if success:
        print(f"\n{'='*50}")
        print("🎉 Создание квеста работает!")
    else:
        print(f"\n{'='*50}")
        print("❌ Проблемы с созданием квеста")

if __name__ == "__main__":
    main()

