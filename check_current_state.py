#!/usr/bin/env python3
"""
Скрипт для проверки текущего состояния серверной базы данных
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

def check_current_state():
    """Проверяет текущее состояние серверной базы данных"""
    print("🔍 Проверка текущего состояния серверной базы данных")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Проверяем структуру таблицы point
        print("\n📍 Проверка структуры таблицы point:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'point' AND table_schema = 'public'
            ORDER BY ordinal_position
        """)
        point_columns = cursor.fetchall()
        
        if point_columns:
            print(f"✅ Структура таблицы point:")
            for col in point_columns:
                print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")
        else:
            print("❌ Таблица point не найдена")

        # Проверяем наличие таблицы point_type
        print("\n📍 Проверка таблицы point_type:")
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
            
            # Проверяем данные в point_type
            cursor.execute("SELECT COUNT(*) FROM point_type")
            point_type_count = cursor.fetchone()[0]
            print(f"📈 Количество записей в point_type: {point_type_count}")
        else:
            print("❌ Таблица point_type не существует")

        # Проверяем наличие таблицы place_settings
        print("\n📍 Проверка таблицы place_settings:")
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'place_settings'
            )
        """)
        place_settings_exists = cursor.fetchone()[0]
        
        if place_settings_exists:
            print("✅ Таблица place_settings существует")
            
            # Проверяем данные в place_settings
            cursor.execute("SELECT COUNT(*) FROM place_settings")
            place_settings_count = cursor.fetchone()[0]
            print(f"📈 Количество записей в place_settings: {place_settings_count}")
        else:
            print("❌ Таблица place_settings не существует")

        # Проверяем статистику всех таблиц
        print("\n📈 Статистика всех таблиц:")
        tables_to_check = ['point', 'category', 'vehicle', 'place', 'activity', 'tool', 'point_type', 'place_settings', 'quest', 'user', 'profile']
        
        for table in tables_to_check:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"  - {table}: {count} записей")
            except Exception as e:
                print(f"  - {table}: ошибка - {e}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_current_state()
    
    if not success:
        print("\n❌ Не удалось проверить состояние базы данных")

if __name__ == "__main__":
    main()
