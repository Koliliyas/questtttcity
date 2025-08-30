#!/usr/bin/env python3
"""
Скрипт для проверки таблиц, связанных с точками в базе данных QuestCity
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

def check_point_related_tables():
    """Проверяет таблицы, связанные с точками"""
    print("🔍 Проверка таблиц, связанных с точками в базе данных QuestCity")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение успешно!")

        # Проверяем все таблицы, которые могут быть связаны с точками
        print("\n🔍 Поиск таблиц, связанных с точками:")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND (table_name LIKE '%point%' OR table_name LIKE '%place%')
            ORDER BY table_name
        """)
        point_tables = cursor.fetchall()
        
        if point_tables:
            print(f"✅ Найдено таблиц, связанных с точками: {len(point_tables)}")
            for table in point_tables:
                print(f"  - {table[0]}")
        else:
            print("❌ Таблицы, связанные с точками, не найдены")

        # Проверяем структуру таблицы point
        print("\n📍 Проверка структуры таблицы point:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'point' 
            ORDER BY ordinal_position
        """)
        point_columns = cursor.fetchall()
        
        if point_columns:
            print(f"✅ Структура таблицы point:")
            for col in point_columns:
                print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")
        else:
            print("❌ Таблица point не найдена")

        # Проверяем структуру таблицы place
        print("\n📍 Проверка структуры таблицы place:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'place' 
            ORDER BY ordinal_position
        """)
        place_columns = cursor.fetchall()
        
        if place_columns:
            print(f"✅ Структура таблицы place:")
            for col in place_columns:
                print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")
        else:
            print("❌ Таблица place не найдена")

        # Проверяем данные в таблице point
        print("\n📍 Проверка данных в таблице point:")
        cursor.execute("SELECT COUNT(*) FROM point")
        point_count = cursor.fetchone()[0]
        print(f"✅ Количество записей в point: {point_count}")

        if point_count > 0:
            cursor.execute("SELECT * FROM point LIMIT 3")
            points = cursor.fetchall()
            print(f"✅ Примеры записей в point:")
            for point in points:
                print(f"  - {point}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_point_related_tables()
    
    if not success:
        print("\n❌ Не удалось проверить таблицы, связанные с точками")

if __name__ == "__main__":
    main()

