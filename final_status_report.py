#!/usr/bin/env python3
"""
Финальный отчет о состоянии базы данных и API
"""
import psycopg2
import requests
from datetime import datetime

# Параметры подключения к внешней базе данных PostgreSQL
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

# Базовый URL API
BASE_URL = "http://questcity.ru/api/v1"

def check_database_status():
    """Проверка состояния базы данных"""
    print("🔍 Проверка состояния базы данных")
    print("=" * 80)

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Проверяем ключевые таблицы
        key_tables = ['user', 'profile', 'point', 'point_type', 'place_settings', 'quest', 'tool', 'category', 'vehicle', 'place', 'activity']
        
        print(f"\n📋 Проверка ключевых таблиц:")
        for table_name in key_tables:
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = %s
                );
            """, (table_name,))
            
            exists = cursor.fetchone()[0]
            if exists:
                cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
                count = cursor.fetchone()[0]
                print(f"  ✅ {table_name}: {count} записей")
            else:
                print(f"  ❌ {table_name}: таблица не существует")

        # Проверяем админа
        print(f"\n📋 Проверка админа:")
        cursor.execute("SELECT COUNT(*) FROM \"user\" WHERE email = 'admin@questcity.com'")
        admin_count = cursor.fetchone()[0]
        print(f"  📊 Админов в базе: {admin_count}")

        if admin_count > 0:
            cursor.execute("SELECT id, username, email, is_active FROM \"user\" WHERE email = 'admin@questcity.com'")
            admin_data = cursor.fetchone()
            print(f"  📄 Данные админа: {admin_data}")

        cursor.close()
        conn.close()
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def check_api_status():
    """Проверка состояния API"""
    print("\n🔍 Проверка состояния API")
    print("=" * 80)

    # Тест 1: Проверка доступности API
    print("\n📋 Тест 1: Проверка доступности API")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        print(f"  📡 Статус ответа: {response.status_code}")
        if response.status_code == 200:
            print("  ✅ API доступен")
        else:
            print(f"  ❌ API недоступен: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка подключения: {e}")

    # Тест 2: Авторизация админа
    print("\n📋 Тест 2: Авторизация админа")
    login_data = {
        "login": "admin@questcity.com",
        "password": "admin123"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/login", data=login_data, timeout=10)
        print(f"  📡 Статус ответа: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            access_token = result.get('accessToken')
            if access_token:
                print("  ✅ Авторизация успешна")
                return True
            else:
                print("  ❌ Токен не найден в ответе")
        else:
            print(f"  ❌ Ошибка авторизации: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
    
    return False

def main():
    print("📊 ФИНАЛЬНЫЙ ОТЧЕТ О СОСТОЯНИИ СИСТЕМЫ")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Проверяем базу данных
    db_ok = check_database_status()
    
    # Проверяем API
    api_ok = check_api_status()
    
    print("\n" + "=" * 80)
    print("📋 ИТОГОВЫЙ СТАТУС:")
    print(f"  🗄️ База данных: {'✅ ОК' if db_ok else '❌ ОШИБКА'}")
    print(f"  🌐 API: {'✅ ОК' if api_ok else '❌ ОШИБКА'}")
    
    if db_ok and api_ok:
        print("\n🎉 СИСТЕМА ПОЛНОСТЬЮ РАБОТАЕТ!")
    else:
        print("\n⚠️ ЕСТЬ ПРОБЛЕМЫ, ТРЕБУЕТСЯ ДОПОЛНИТЕЛЬНАЯ ДИАГНОСТИКА")
    
    print("\n" + "=" * 80)
    print("✅ Отчет завершен")

if __name__ == "__main__":
    main()
