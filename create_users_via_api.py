#!/usr/bin/env python3
"""
Скрипт для создания пользователей QuestCity через API регистрации
"""

import requests
import json
from datetime import datetime

def create_user_via_api(email, password, role="user"):
    """Создает пользователя через API регистрации"""
    print(f"🔐 Создание пользователя через API")
    print("=" * 50)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"👤 Email: {email}")
    print(f"🔑 Role: {role}")
    print()

    base_url = "http://questcity.ru/api/v1/"
    
    # Данные для регистрации
    registration_data = {
        "email": email,
        "password": password,
        "role": role
    }

    try:
        # Пробуем endpoint регистрации
        response = requests.post(
            f"{base_url}auth/register",
            json=registration_data,
            timeout=10,
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json"
            }
        )

        print(f"📡 HTTP статус: {response.status_code}")
        print(f"📄 Заголовки ответа: {dict(response.headers)}")
        print()

        if response.status_code == 201 or response.status_code == 200:
            data = response.json()
            print("✅ Пользователь создан успешно!")
            print(f"📊 Ответ API:")
            print(json.dumps(data, indent=2, ensure_ascii=False))
            return True
                
        elif response.status_code == 422:
            print("❌ Ошибка валидации данных")
            print(f"📄 Ответ: {response.text}")
            return False
            
        elif response.status_code == 409:
            print("⚠️ Пользователь уже существует")
            print(f"📄 Ответ: {response.text}")
            return True
            
        else:
            print(f"❌ Ошибка: {response.status_code}")
            print(f"📄 Ответ: {response.text}")
            return False

    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка подключения: {e}")
        return False

def test_login_after_creation(email, password):
    """Тестирует вход после создания пользователя"""
    print(f"\n🧪 Тестирование входа для {email}...")
    
    base_url = "http://questcity.ru/api/v1/"
    
    login_data = {
        "login": email,
        "password": password
    }

    try:
        response = requests.post(
            f"{base_url}auth/login",
            data=login_data,
            timeout=10,
            headers={
                "Accept": "application/json"
            }
        )

        if response.status_code == 200:
            data = response.json()
            print("✅ Вход успешен!")
            if "access_token" in data:
                print(f"🔑 Токен получен: {data['access_token'][:20]}...")
            return True
        else:
            print(f"❌ Вход не удался: {response.status_code}")
            print(f"📄 Ответ: {response.text}")
            return False

    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка подключения: {e}")
        return False

def main():
    print("🚀 Создание пользователей QuestCity через API")
    print("=" * 60)
    
    # Создаем администратора
    print("\n👑 Создание администратора...")
    admin_created = create_user_via_api(
        email="admin@questcity.com",
        password="admin123",
        role="admin"
    )
    
    if admin_created:
        test_login_after_creation("admin@questcity.com", "admin123")
    
    # Создаем тестового пользователя
    print("\n👤 Создание тестового пользователя...")
    user_created = create_user_via_api(
        email="testuser@questcity.com",
        password="password123",
        role="user"
    )
    
    if user_created:
        test_login_after_creation("testuser@questcity.com", "password123")
    
    print("\n" + "=" * 60)
    print("🏁 Создание пользователей завершено")
    
    if admin_created or user_created:
        print("\n✅ Готово! Теперь можно войти в систему:")
        print("👑 Администратор: admin@questcity.com / admin123")
        print("👤 Пользователь: testuser@questcity.com / password123")
    else:
        print("\n❌ Не удалось создать пользователей")
        print("🔧 Возможно, нужно создать их напрямую в базе данных")

if __name__ == "__main__":
    main()

