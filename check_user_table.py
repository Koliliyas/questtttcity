#!/usr/bin/env python3
"""
Скрипт для проверки структуры таблицы user в базе данных QuestCity
"""

import psycopg2
from datetime import datetime

# Параметры подключения к базе данных
DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr'
}

def check_user_table():
    """Проверяет структуру таблицы user"""
    print("🔍 Проверка таблицы user в базе данных QuestCity")
    print("=" * 50)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключаемся к базе данных
        print("🔌 Подключение к базе данных...")
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение успешно!")

        # Проверяем структуру таблицы user
        print("\n👥 Структура таблицы user:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'user' 
            ORDER BY ordinal_position
        """)
        columns = cursor.fetchall()
        
        for col in columns:
            default = col[3] if col[3] else "NULL"
            print(f"  - {col[0]}: {col[1]} ({'NULL' if col[2] == 'YES' else 'NOT NULL'}) DEFAULT: {default}")

        # Проверяем существующих пользователей
        print("\n👥 Существующие пользователи:")
        cursor.execute("SELECT id, email, role, is_verified FROM \"user\"")
        existing_users = cursor.fetchall()
        
        if existing_users:
            print(f"Найдено пользователей: {len(existing_users)}")
            for user in existing_users:
                print(f"  - ID: {user[0]}, Email: {user[1]}, Role: {user[2]}, Verified: {user[3]}")
        else:
            print("Пользователи не найдены")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 50)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_user_table()
    
    if not success:
        print("\n❌ Не удалось проверить таблицу user")

if __name__ == "__main__":
    main()

