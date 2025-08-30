#!/usr/bin/env python3
"""
Скрипт для проверки типов точек в базе данных QuestCity
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

def check_point_types():
    """Проверяет типы точек в базе данных"""
    print("🔍 Проверка типов точек в базе данных QuestCity")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение успешно!")

        # Проверяем таблицу point_type
        print("\n🎯 Проверка таблицы point_type:")
        cursor.execute("""
            SELECT id, name, description
            FROM point_type 
            ORDER BY id
        """)
        point_types = cursor.fetchall()
        
        if point_types:
            print(f"✅ Найдено типов точек: {len(point_types)}")
            for pt in point_types:
                print(f"  - ID: {pt[0]}, Name: {pt[1]}, Description: {pt[2]}")
        else:
            print("❌ Типы точек не найдены")

        # Проверяем таблицу activity (возможно, это и есть типы точек)
        print("\n🎯 Проверка таблицы activity:")
        cursor.execute("""
            SELECT id, name, description
            FROM activity 
            ORDER BY id
        """)
        activities = cursor.fetchall()
        
        if activities:
            print(f"✅ Найдено активностей: {len(activities)}")
            for act in activities:
                print(f"  - ID: {act[0]}, Name: {act[1]}, Description: {act[2]}")
        else:
            print("❌ Активности не найдены")

        # Проверяем все таблицы, которые могут содержать типы
        print("\n🔍 Поиск таблиц с типами:")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name LIKE '%type%'
            ORDER BY table_name
        """)
        type_tables = cursor.fetchall()
        
        if type_tables:
            print(f"✅ Найдено таблиц с 'type': {len(type_tables)}")
            for table in type_tables:
                print(f"  - {table[0]}")
        else:
            print("❌ Таблицы с 'type' не найдены")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_point_types()
    
    if not success:
        print("\n❌ Не удалось проверить типы точек")

if __name__ == "__main__":
    main()

