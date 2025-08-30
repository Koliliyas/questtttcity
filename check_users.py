#!/usr/bin/env python3
"""
Скрипт для проверки пользователей в базе данных QuestCity
"""

import requests
import json
from datetime import datetime

def check_users_in_db():
    """Проверяем пользователей через API"""
    print("🔍 Проверка пользователей в базе данных QuestCity")
    print("=" * 60)
    print(f"📅 Время проверки: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Попробуем получить список пользователей (если есть публичный endpoint)
    base_url = "http://questcity.ru/api/v1/"
    
    # Проверим разные endpoints
    endpoints = [
        "users/",
        "users",
        "admin/users/",
        "admin/users"
    ]
    
    for endpoint in endpoints:
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=10)
            print(f"🔍 Проверка {endpoint}: {response.status_code}")
            if response.status_code == 200:
                print(f"✅ Endpoint {endpoint} работает!")
                data = response.json()
                print(f"📊 Данные: {json.dumps(data, indent=2, ensure_ascii=False)}")
                break
        except:
            print(f"❌ Endpoint {endpoint} недоступен")
    
    print()
    print("🔧 Рекомендации:")
    print("1. Проверьте, что пользователи созданы в базе данных")
    print("2. Возможно, нужно создать администратора заново")
    print("3. Проверьте пароли пользователей")

def test_simple_login():
    """Тестируем простые комбинации логин/пароль"""
    print("\n🧪 Тестирование простых комбинаций:")
    
    test_combinations = [
        {"login": "admin", "password": "admin"},
        {"login": "admin@questcity.com", "password": "admin"},
        {"login": "admin", "password": "admin123"},
        {"login": "test", "password": "test"},
        {"login": "user", "password": "user"},
    ]
    
    base_url = "http://questcity.ru/api/v1/"
    
    for combo in test_combinations:
        try:
            response = requests.post(
                f"{base_url}auth/login",
                data=combo,
                timeout=5,
                headers={"Accept": "application/json"}
            )
            
            if response.status_code == 200:
                print(f"✅ УСПЕХ! {combo['login']} / {combo['password']}")
                data = response.json()
                print(f"📊 Ответ: {json.dumps(data, indent=2, ensure_ascii=False)}")
                return combo
            else:
                print(f"❌ {combo['login']} / {combo['password']} - {response.status_code}")
                
        except Exception as e:
            print(f"❌ Ошибка тестирования {combo['login']}: {e}")
    
    return None

def main():
    check_users_in_db()
    
    print("\n" + "="*60)
    print("🧪 Тестирование простых комбинаций логин/пароль")
    print("="*60)
    
    working_combo = test_simple_login()
    
    if working_combo:
        print(f"\n🎉 НАЙДЕНА РАБОЧАЯ КОМБИНАЦИЯ!")
        print(f"👤 Login: {working_combo['login']}")
        print(f"🔑 Password: {working_combo['password']}")
    else:
        print(f"\n❌ Рабочие комбинации не найдены")
        print("🔧 Нужно создать пользователей в базе данных")

if __name__ == "__main__":
    main()

