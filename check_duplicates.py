#!/usr/bin/env python3
"""
Скрипт для проверки дублирования данных в базе данных QuestCity
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

def check_duplicates():
    """Проверяет дублирование данных в базе"""
    print("🔍 Проверка дублирования данных в базе QuestCity")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение успешно!")

        # Проверяем дублирование в category
        print("\n🏷️ Проверка дублирования в category:")
        cursor.execute("""
            SELECT id, name, COUNT(*) as count
            FROM category 
            GROUP BY id, name 
            HAVING COUNT(*) > 1
            ORDER BY id
        """)
        duplicates = cursor.fetchall()
        
        if duplicates:
            print(f"❌ Найдено дублирований: {len(duplicates)}")
            for dup in duplicates:
                print(f"  - ID: {dup[0]}, Name: {dup[1]}, Count: {dup[2]}")
        else:
            print("✅ Дублирований не найдено")

        # Проверяем дублирование в vehicle
        print("\n🚗 Проверка дублирования в vehicle:")
        cursor.execute("""
            SELECT id, name, COUNT(*) as count
            FROM vehicle 
            GROUP BY id, name 
            HAVING COUNT(*) > 1
            ORDER BY id
        """)
        duplicates = cursor.fetchall()
        
        if duplicates:
            print(f"❌ Найдено дублирований: {len(duplicates)}")
            for dup in duplicates:
                print(f"  - ID: {dup[0]}, Name: {dup[1]}, Count: {dup[2]}")
        else:
            print("✅ Дублирований не найдено")

        # Проверяем дублирование в place
        print("\n📍 Проверка дублирования в place:")
        cursor.execute("""
            SELECT id, name, COUNT(*) as count
            FROM place 
            GROUP BY id, name 
            HAVING COUNT(*) > 1
            ORDER BY id
        """)
        duplicates = cursor.fetchall()
        
        if duplicates:
            print(f"❌ Найдено дублирований: {len(duplicates)}")
            for dup in duplicates:
                print(f"  - ID: {dup[0]}, Name: {dup[1]}, Count: {dup[2]}")
        else:
            print("✅ Дублирований не найдено")

        # Проверяем дублирование в activity
        print("\n🎯 Проверка дублирования в activity:")
        cursor.execute("""
            SELECT id, name, COUNT(*) as count
            FROM activity 
            GROUP BY id, name 
            HAVING COUNT(*) > 1
            ORDER BY id
        """)
        duplicates = cursor.fetchall()
        
        if duplicates:
            print(f"❌ Найдено дублирований: {len(duplicates)}")
            for dup in duplicates:
                print(f"  - ID: {dup[0]}, Name: {dup[1]}, Count: {dup[2]}")
        else:
            print("✅ Дублирований не найдено")

        # Проверяем дублирование в tool
        print("\n🔧 Проверка дублирования в tool:")
        cursor.execute("""
            SELECT id, name, COUNT(*) as count
            FROM tool 
            GROUP BY id, name 
            HAVING COUNT(*) > 1
            ORDER BY id
        """)
        duplicates = cursor.fetchall()
        
        if duplicates:
            print(f"❌ Найдено дублирований: {len(duplicates)}")
            for dup in duplicates:
                print(f"  - ID: {dup[0]}, Name: {dup[1]}, Count: {dup[2]}")
        else:
            print("✅ Дублирований не найдено")

        # Проверяем общее количество записей
        print("\n📊 Общее количество записей:")
        tables = ['category', 'vehicle', 'place', 'activity', 'tool']
        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            print(f"  - {table}: {count} записей")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_duplicates()
    
    if not success:
        print("\n❌ Не удалось проверить дублирование")

if __name__ == "__main__":
    main()

