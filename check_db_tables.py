#!/usr/bin/env python3
"""
Скрипт для проверки таблиц в базе данных QuestCity
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

def check_database():
    """Проверяет структуру базы данных"""
    print("🔍 Проверка базы данных QuestCity")
    print("=" * 50)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключаемся к базе данных
        print("🔌 Подключение к базе данных...")
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение успешно!")

        # Проверяем все таблицы
        print("\n📋 Все таблицы в базе данных:")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        """)
        tables = cursor.fetchall()
        
        if tables:
            for table in tables:
                print(f"  - {table[0]}")
        else:
            print("  Таблицы не найдены")

        # Проверяем схему базы данных
        print("\n🏗️ Схемы в базе данных:")
        cursor.execute("""
            SELECT schema_name 
            FROM information_schema.schemata 
            ORDER BY schema_name
        """)
        schemas = cursor.fetchall()
        
        for schema in schemas:
            print(f"  - {schema[0]}")

        # Если есть таблица users, проверяем её структуру
        if any('users' in table[0].lower() for table in tables):
            print("\n👥 Структура таблицы users:")
            cursor.execute("""
                SELECT column_name, data_type, is_nullable 
                FROM information_schema.columns 
                WHERE table_name = 'users' 
                ORDER BY ordinal_position
            """)
            columns = cursor.fetchall()
            
            for col in columns:
                print(f"  - {col[0]}: {col[1]} ({'NULL' if col[2] == 'YES' else 'NOT NULL'})")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 50)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_database()
    
    if not success:
        print("\n❌ Не удалось проверить базу данных")

if __name__ == "__main__":
    main()

