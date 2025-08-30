#!/usr/bin/env python3
"""
Скрипт для тестирования входа в QuestCity через API
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
    print(f"👤 Email: {email}")
    print()

    # Данные для входа
    login_data = {
        "email": email,
        "password": password
    }

    try:
        # Отправляем запрос на вход
        response = requests.post(
            f"{base_url}auth/login",
            json=login_data,
            timeout=10,
            headers={
                "Content-Type": "application/json",
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

def test_user_info(token, base_url="http://questcity.ru/api/v1/"):
    """Тест получения информации о пользователе"""
    if not token:
        return
        
    print(f"\n👤 Получение информации о пользователе...")
    
    try:
        response = requests.get(
            f"{base_url}users/me",
            headers={
                "Authorization": f"Bearer {token}",
                "Accept": "application/json"
            },
            timeout=10
        )
        
        print(f"📡 HTTP статус: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Информация о пользователе получена!")
            print(f"📊 Данные пользователя:")
            print(json.dumps(data, indent=2, ensure_ascii=False))
        else:
            print(f"❌ Ошибка получения данных: {response.status_code}")
            print(f"📄 Ответ: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка подключения: {e}")

def main():
    # Тестируем разные учетные данные
    test_accounts = [
        {
            "email": "admin@questcity.com",
            "password": "admin123",
            "description": "Основной администратор"
        },
        {
            "email": "adminuser@questcity.com", 
            "password": "adminuser123",
            "description": "Альтернативный администратор"
        },
        {
            "email": "testuser@questcity.com",
            "password": "password123", 
            "description": "Тестовый пользователь"
        }
    ]
    
    for account in test_accounts:
        print(f"\n{'='*60}")
        print(f"🧪 Тест: {account['description']}")
        print(f"{'='*60}")
        
        token = test_login(account["email"], account["password"])
        
        if token:
            test_user_info(token)
            print(f"\n✅ {account['description']} - ВХОД УСПЕШЕН!")
            break
        else:
            print(f"\n❌ {account['description']} - ВХОД НЕ УДАЛСЯ")
    
    print(f"\n{'='*60}")
    print("🏁 Тестирование завершено")

if __name__ == "__main__":
    main()

