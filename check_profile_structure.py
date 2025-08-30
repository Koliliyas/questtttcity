#!/usr/bin/env python3
"""
Скрипт для проверки структуры таблицы profile
"""
import psycopg2
from datetime import datetime

# Параметры подключения к серверной базе данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr'
}

def check_profile_structure():
    """Проверяет структуру таблицы profile"""
    print("🔍 Проверка структуры таблицы profile")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Проверяем структуру таблицы profile
        print("\n📍 Структура таблицы profile:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'profile' AND table_schema = 'public'
            ORDER BY ordinal_position
        """)
        profile_columns = cursor.fetchall()
        
        if profile_columns:
            print(f"✅ Структура таблицы profile:")
            for col in profile_columns:
                print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")
        else:
            print("❌ Таблица profile не найдена")

        # Проверяем данные в таблице profile
        print("\n📍 Данные в таблице profile:")
        cursor.execute("SELECT COUNT(*) FROM profile")
        profile_count = cursor.fetchone()[0]
        print(f"📈 Количество записей в profile: {profile_count}")

        if profile_count > 0:
            cursor.execute("SELECT * FROM profile LIMIT 5")
            profiles = cursor.fetchall()
            print(f"✅ Примеры записей в profile:")
            for profile in profiles:
                print(f"  - {profile}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_profile_structure()
    
    if not success:
        print("\n❌ Не удалось проверить структуру таблицы profile")

if __name__ == "__main__":
    main()
