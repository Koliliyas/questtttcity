#!/usr/bin/env python3
"""
Скрипт для тестирования входа в QuestCity через API с form-data
"""

import requests
import json
from datetime import datetime

def test_login_form(login, password, base_url="http://questcity.ru/api/v1/"):
    """Тест входа через API с form-data"""
    print(f"🔐 Тестирование входа в QuestCity API (form-data)")
    print("=" * 50)
    print(f"📅 Время теста: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 API URL: {base_url}")
    print(f"👤 Login: {login}")
    print()

    # Данные для входа как form-data
    login_data = {
        "login": login,
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

def test_api_documentation(base_url="http://questcity.ru/api/v1/"):
    """Проверяем документацию API"""
    print(f"📚 Проверка документации API...")
    
    try:
        response = requests.get(f"{base_url}docs", timeout=10)
        if response.status_code == 200:
            print("✅ Swagger документация доступна")
            print(f"📄 URL: {base_url}docs")
        else:
            print(f"❌ Документация недоступна: {response.status_code}")
    except:
        print("❌ Не удалось получить документацию")

def main():
    # Сначала проверим документацию
    test_api_documentation()
    
    print(f"\n{'='*60}")
    
    # Тестируем вход с form-data
    test_accounts = [
        {
            "login": "admin@questcity.com",
            "password": "admin123",
            "description": "Основной администратор"
        },
        {
            "login": "adminuser@questcity.com", 
            "password": "adminuser123",
            "description": "Альтернативный администратор"
        },
        {
            "login": "testuser@questcity.com",
            "password": "password123", 
            "description": "Тестовый пользователь"
        }
    ]
    
    for account in test_accounts:
        print(f"\n{'='*60}")
        print(f"🧪 Тест: {account['description']}")
        print(f"{'='*60}")
        
        token = test_login_form(account["login"], account["password"])
        
        if token:
            print(f"\n✅ {account['description']} - ВХОД УСПЕШЕН!")
            break
        else:
            print(f"\n❌ {account['description']} - ВХОД НЕ УДАЛСЯ")
    
    print(f"\n{'='*60}")
    print("🏁 Тестирование завершено")

if __name__ == "__main__":
    main()

