#!/usr/bin/env python3
"""
Скрипт для проверки структуры локальной базы данных
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

def check_local_database():
    """Проверяет структуру локальной базы данных"""
    print("🔍 Проверка структуры локальной базы данных")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к локальной базе
        print("🔗 Подключение к локальной базе данных...")
        conn = psycopg2.connect(**LOCAL_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к локальной базе успешно!")

        # Получаем список всех таблиц
        print("\n📋 Список всех таблиц в локальной базе:")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        """)
        tables = cursor.fetchall()
        
        for table in tables:
            table_name = table[0]
            print(f"  - {table_name}")

        # Проверяем структуру ключевых таблиц
        key_tables = ['point', 'point_type', 'place_settings', 'profile', 'user', 'quest', 'category', 'vehicle', 'place', 'activity', 'tool']
        
        print(f"\n🔍 Структура ключевых таблиц:")
        for table_name in key_tables:
            try:
                cursor.execute(f"""
                    SELECT column_name, data_type, is_nullable, column_default
                    FROM information_schema.columns 
                    WHERE table_name = '{table_name}' AND table_schema = 'public'
                    ORDER BY ordinal_position
                """)
                columns = cursor.fetchall()
                
                if columns:
                    print(f"\n📍 Таблица {table_name}:")
                    for col in columns:
                        default = col[3] if col[3] else 'NULL'
                        print(f"  - {col[0]}: {col[1]} (nullable: {col[2]}, default: {default})")
                else:
                    print(f"\n❌ Таблица {table_name} не найдена")
                    
            except Exception as e:
                print(f"\n❌ Ошибка при проверке таблицы {table_name}: {e}")

        # Проверяем данные в ключевых таблицах
        print(f"\n📊 Данные в ключевых таблицах:")
        for table_name in key_tables:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
                count = cursor.fetchone()[0]
                print(f"  - {table_name}: {count} записей")
                
                # Показываем примеры данных для небольших таблиц
                if count > 0 and count <= 10:
                    cursor.execute(f"SELECT * FROM {table_name} LIMIT 3")
                    rows = cursor.fetchall()
                    print(f"    Примеры: {rows}")
                    
            except Exception as e:
                print(f"  - {table_name}: ошибка - {e}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Проверка локальной базы данных завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_local_database()
    
    if not success:
        print("\n❌ Не удалось проверить локальную базу данных")

if __name__ == "__main__":
    main()
