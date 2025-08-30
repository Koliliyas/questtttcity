#!/usr/bin/env python3
"""
Скрипт для проверки структуры таблицы activity
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

def check_activity_structure():
    """Проверяет структуру таблицы activity"""
    print("🔍 Проверка структуры таблицы activity")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Проверяем структуру таблицы activity
        print("\n📍 Структура таблицы activity:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'activity' AND table_schema = 'public'
            ORDER BY ordinal_position
        """)
        activity_columns = cursor.fetchall()
        
        if activity_columns:
            print(f"✅ Структура таблицы activity:")
            for col in activity_columns:
                print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")
        else:
            print("❌ Таблица activity не найдена")

        # Проверяем данные в таблице activity
        print("\n📍 Данные в таблице activity:")
        cursor.execute("SELECT COUNT(*) FROM activity")
        activity_count = cursor.fetchone()[0]
        print(f"📈 Количество записей в activity: {activity_count}")

        if activity_count > 0:
            cursor.execute("SELECT * FROM activity LIMIT 5")
            activities = cursor.fetchall()
            print(f"✅ Примеры записей в activity:")
            for activity in activities:
                print(f"  - {activity}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_activity_structure()
    
    if not success:
        print("\n❌ Не удалось проверить структуру таблицы activity")

if __name__ == "__main__":
    main()
