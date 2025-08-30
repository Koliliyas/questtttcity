#!/usr/bin/env python3
"""
Скрипт для проверки таблиц, связанных с точками в локальной базе данных
"""
import psycopg2
from datetime import datetime

# Параметры подключения к локальной базе данных
LOCAL_DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'questcity',
    'user': 'postgres',
    'password': 'postgres'
}

def check_local_point_tables():
    """Проверяет таблицы, связанные с точками в локальной базе"""
    print("🔍 Проверка таблиц, связанных с точками в локальной базе данных")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        conn = psycopg2.connect(**LOCAL_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к локальной базе успешно!")

        # Проверяем все таблицы, которые могут быть связаны с точками
        print("\n🔍 Поиск таблиц, связанных с точками:")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND (table_name LIKE '%point%' OR table_name LIKE '%place%' OR table_name LIKE '%location%')
            ORDER BY table_name
        """)
        point_tables = cursor.fetchall()
        
        if point_tables:
            print(f"✅ Найдено таблиц, связанных с точками: {len(point_tables)}")
            for table in point_tables:
                print(f"  - {table[0]}")
        else:
            print("❌ Таблицы, связанные с точками, не найдены")

        # Проверяем структуру таблицы point в локальной базе
        print("\n📍 Проверка структуры таблицы point в локальной базе:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'point' AND table_schema = 'public'
            ORDER BY ordinal_position
        """)
        point_columns = cursor.fetchall()
        
        if point_columns:
            print(f"✅ Структура таблицы point в локальной базе:")
            for col in point_columns:
                print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")
        else:
            print("❌ Таблица point не найдена в локальной базе")

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

        # Проверяем все таблицы в базе
        print("\n📋 Все таблицы в локальной базе:")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        """)
        all_tables = cursor.fetchall()
        
        if all_tables:
            print(f"✅ Найдено таблиц: {len(all_tables)}")
            for table in all_tables:
                print(f"  - {table[0]}")
        else:
            print("❌ Таблицы не найдены")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_local_point_tables()
    
    if not success:
        print("\n❌ Не удалось проверить таблицы в локальной базе")

if __name__ == "__main__":
    main()

