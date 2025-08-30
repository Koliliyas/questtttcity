#!/usr/bin/env python3
"""
Тестовый скрипт для проверки входа с новыми пользователями QuestCity
"""

import requests
import json
from datetime import datetime

def test_login(email, password, base_url="http://questcity.ru/api/v1/"):
    """Тест входа через API"""
    print(f"🔐 Тестирование входа в QuestCity API")
    print("=" * 50)
    print(f"📅 Время теста: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 API URL: {base_url}")
    print(f"👤 Login: {email}")
    print(f"🔑 Password: {password}")
    print()

    # Данные для входа как form-data
    login_data = {
        "login": email,
        "password": password
    }

    try:
        # Отправляем запрос на вход с form-data
        response = requests.post(
            f"{base_url}auth/login",
            data=login_data,  # form-data вместо json
            timeout=10,
            headers={
                "Accept": "application/json"
            }
        )

        print(f"📡 HTTP статус: {response.status_code}")
        print(f"📄 Заголовки ответа: {dict(response.headers)}")
        print()

        if response.status_code == 200:
            data = response.json()
            print("✅ Вход успешен!")
            print(f"📊 Ответ API:")
            print(json.dumps(data, indent=2, ensure_ascii=False))
            
            # Проверяем токен
            if "access_token" in data:
                print(f"\n🔑 Токен получен: {data['access_token'][:20]}...")
                return data["access_token"]
            else:
                print("⚠️ Токен не найден в ответе")
                return None
                
        elif response.status_code == 401:
            print("❌ Неверные учетные данные")
            print(f"📄 Ответ: {response.text}")
            return None
            
        elif response.status_code == 422:
            print("❌ Ошибка валидации данных")
            print(f"📄 Ответ: {response.text}")
            return None
            
        else:
            print(f"❌ Ошибка: {response.status_code}")
            print(f"📄 Ответ: {response.text}")
            return None

    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка подключения: {e}")
        return None

def main():
    print("🧪 Тестирование входа с новыми пользователями QuestCity")
    print("=" * 60)
    
    # Тестируем новых пользователей
    test_accounts = [
        {
            "email": "admin@questcity.com",
            "password": "Admin123!",
            "description": "Новый администратор"
        },
        {
            "email": "testuser@questcity.com",
            "password": "Password123!",
            "description": "Новый тестовый пользователь"
        }
    ]
    
    for account in test_accounts:
        print(f"\n{'='*60}")
        print(f"🧪 Тест: {account['description']}")
        print(f"{'='*60}")
        
        token = test_login(account["email"], account["password"])
        
        if token:
            print(f"\n✅ {account['description']} - ВХОД УСПЕШЕН!")
            break
        else:
            print(f"\n❌ {account['description']} - ВХОД НЕ УДАЛСЯ")
    
    print(f"\n{'='*60}")
    print("🏁 Тестирование завершено")

if __name__ == "__main__":
    main()

