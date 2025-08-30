#!/usr/bin/env python3
"""
Исправленный тестовый скрипт для проверки создания квеста через QuestCity API
"""
import requests
import json
from datetime import datetime

def test_quest_creation(base_url="http://questcity.ru/api/v1/"):
    """Тест создания квеста через API с исправленными данными"""
    print(f"🎯 Тестирование создания квеста в QuestCity API")
    print("=" * 60)
    print(f"📅 Время теста: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 API URL: {base_url}")
    print()

    # Сначала получаем токен для администратора
    print("🔐 Получение токена администратора...")
    login_data = {
        "login": "admin@questcity.com",
        "password": "Admin123!"
    }

    try:
        # Входим как администратор
        login_response = requests.post(
            f"{base_url}auth/login",
            data=login_data,
            timeout=10,
            headers={"Accept": "application/json"}
        )

        if login_response.status_code != 200:
            print(f"❌ Ошибка входа: {login_response.status_code}")
            print(f"📄 Ответ: {login_response.text}")
            return False

        login_result = login_response.json()
        if "accessToken" not in login_result:
            print("❌ Токен не найден в ответе")
            return False

        access_token = login_result["accessToken"]
        print(f"✅ Токен получен: {access_token[:20]}...")

        # Исправленные тестовые данные для создания квеста
        quest_data = {
            "name": "Тестовый квест",
            "description": "Описание тестового квеста для проверки API",
            "image": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=",
            "credits": {
                "cost": 0,
                "reward": 100
            },
            "main_preferences": {
                "level": "Easy",  # Исправлено: 'Easy' вместо 'EASY'
                "mileage": "5-10",  # Исправлено: '5-10' вместо 'UP_TO_TEN'
                "category_id": 1,
                "vehicle_id": 1,
                "place_id": 1,
                "group": 2,  # Исправлено: 2 вместо 'TWO'
                "timeframe": 1  # Исправлено: 1 вместо 'ONE_HOUR'
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
                            "detections_radius": 5,  # Исправлено: 5 вместо 50 (максимум 10)
                            "height": 0,
                            "interaction_inaccuracy": 5,
                            "part": 1,
                            "random_occurrence": 5  # Исправлено: 5 вместо false (минимум 5)
                        }
                    ],
                    "tool_id": None,
                    "file": None,
                    "is_divide": False
                }
            ]
        }

        print("\n📝 Отправка исправленных данных для создания квеста...")
        print(f"📊 Данные: {json.dumps(quest_data, indent=2, ensure_ascii=False)}")

        # Отправляем запрос на создание квеста
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }

        # Пробуем разные endpoints для создания квеста
        endpoints = [
            "quests/",
            "quests/create",
            "quests/admin/create"
        ]

        for endpoint in endpoints:
            print(f"\n🔗 Тестирование endpoint: {endpoint}")
            
            try:
                response = requests.post(
                    f"{base_url}{endpoint}",
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

            except requests.exceptions.RequestException as e:
                print(f"❌ Ошибка подключения: {e}")

        print("\n❌ Все endpoints для создания квеста не сработали")
        return False

    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка подключения: {e}")
        return False

def main():
    print("🧪 Тестирование создания квеста QuestCity (исправленная версия)")
    print("=" * 60)
    
    success = test_quest_creation()
    
    if success:
        print(f"\n{'='*60}")
        print("🎉 Создание квеста работает!")
    else:
        print(f"\n{'='*60}")
        print("❌ Проблемы с созданием квеста")
        print("\n🔍 Возможные причины:")
        print("1. Неправильная структура данных")
        print("2. Отсутствие прав у пользователя")
        print("3. Проблемы с валидацией")
        print("4. Ошибки в backend логике")

if __name__ == "__main__":
    main()

