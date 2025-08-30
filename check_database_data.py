#!/usr/bin/env python3
"""
Скрипт для проверки данных в базе данных QuestCity
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

def check_database_data():
    """Проверяет данные в базе данных"""
    print("🔍 Проверка данных в базе данных QuestCity")
    print("=" * 60)
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

        # Проверяем данные в таблице category
        print("\n🏷️ Данные в таблице category:")
        cursor.execute("SELECT id, name, image FROM category ORDER BY id")
        categories = cursor.fetchall()
        
        if categories:
            print(f"Найдено категорий: {len(categories)}")
            for cat in categories:
                print(f"  - ID: {cat[0]}, Name: {cat[1]}, Image: {cat[2]}")
        else:
            print("Категории не найдены")

        # Проверяем данные в таблице vehicle
        print("\n🚗 Данные в таблице vehicle:")
        cursor.execute("SELECT id, name FROM vehicle ORDER BY id")
        vehicles = cursor.fetchall()
        
        if vehicles:
            print(f"Найдено типов транспорта: {len(vehicles)}")
            for veh in vehicles:
                print(f"  - ID: {veh[0]}, Name: {veh[1]}")
        else:
            print("Типы транспорта не найдены")

        # Проверяем данные в таблице place
        print("\n📍 Данные в таблице place:")
        cursor.execute("SELECT id, name FROM place ORDER BY id")
        places = cursor.fetchall()
        
        if places:
            print(f"Найдено мест: {len(places)}")
            for place in places:
                print(f"  - ID: {place[0]}, Name: {place[1]}")
        else:
            print("Места не найдены")

        # Проверяем данные в таблице activity
        print("\n🎯 Данные в таблице activity:")
        cursor.execute("SELECT id, name FROM activity ORDER BY id")
        activities = cursor.fetchall()
        
        if activities:
            print(f"Найдено активностей: {len(activities)}")
            for act in activities:
                print(f"  - ID: {act[0]}, Name: {act[1]}")
        else:
            print("Активности не найдены")

        # Проверяем данные в таблице tool
        print("\n🔧 Данные в таблице tool:")
        cursor.execute("SELECT id, name, image FROM tool ORDER BY id")
        tools = cursor.fetchall()
        
        if tools:
            print(f"Найдено инструментов: {len(tools)}")
            for tool in tools:
                print(f"  - ID: {tool[0]}, Name: {tool[1]}, Image: {tool[2]}")
        else:
            print("Инструменты не найдены")

        # Проверяем данные в таблице user
        print("\n👥 Данные в таблице user:")
        cursor.execute('SELECT id, email, role, is_verified FROM "user" ORDER BY id')
        users = cursor.fetchall()
        
        if users:
            print(f"Найдено пользователей: {len(users)}")
            for user in users:
                role_name = "ADMIN" if user[2] == 2 else "USER" if user[2] == 0 else "MODERATOR"
                print(f"  - ID: {user[0][:8]}..., Email: {user[1]}, Role: {role_name}, Verified: {user[3]}")
        else:
            print("Пользователи не найдены")

        # Проверяем данные в таблице quest
        print("\n🎮 Данные в таблице quest:")
        cursor.execute("SELECT id, name, description FROM quest ORDER BY id")
        quests = cursor.fetchall()
        
        if quests:
            print(f"Найдено квестов: {len(quests)}")
            for quest in quests:
                print(f"  - ID: {quest[0]}, Name: {quest[1]}, Description: {quest[2][:50]}...")
        else:
            print("Квесты не найдены")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_database_data()
    
    if not success:
        print("\n❌ Не удалось проверить базу данных")

if __name__ == "__main__":
    main()

