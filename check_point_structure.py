#!/usr/bin/env python3
"""
Скрипт для проверки структуры таблицы point на сервере
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

def check_point_structure():
    """Проверяет структуру таблицы point на сервере"""
    print("🔍 Проверка структуры таблицы point на сервере")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Проверяем существование таблицы point
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'point'
            )
        """)
        point_exists = cursor.fetchone()[0]
        
        if not point_exists:
            print("❌ Таблица point не существует!")
            return False

        print("✅ Таблица point существует")

        # Проверяем структуру таблицы point
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'point' AND table_schema = 'public'
            ORDER BY ordinal_position
        """)
        point_columns = cursor.fetchall()
        
        print(f"\n📍 Структура таблицы point:")
        for col in point_columns:
            print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")

        # Проверяем данные в таблице point
        cursor.execute("SELECT COUNT(*) FROM point")
        point_count = cursor.fetchone()[0]
        print(f"\n📈 Количество записей в point: {point_count}")

        # Проверяем существование таблицы point_type
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'point_type'
            )
        """)
        point_type_exists = cursor.fetchone()[0]
        
        if point_type_exists:
            print("✅ Таблица point_type существует")
            cursor.execute("SELECT COUNT(*) FROM point_type")
            point_type_count = cursor.fetchone()[0]
            print(f"📈 Количество записей в point_type: {point_type_count}")
        else:
            print("❌ Таблица point_type не существует")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_point_structure()
    
    if not success:
        print("\n❌ Не удалось проверить структуру таблицы point")

if __name__ == "__main__":
    main()
