#!/usr/bin/env python3
"""
Поиск таблиц, связанных с пользователями (исправленная версия)
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

def find_user_tables():
    """Ищет таблицы, связанные с пользователями"""
    print("🔍 Поиск таблиц, связанных с пользователями")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к локальной базе
        print("🔗 Подключение к локальной базе данных...")
        conn = psycopg2.connect(**LOCAL_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к локальной базе успешно!")

        # Ищем все таблицы, которые могут быть связаны с пользователями
        print("\n🔍 Поиск таблиц с названиями, содержащими 'user':")
        cursor.execute("""
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_type = 'BASE TABLE' 
            AND (table_name ILIKE '%user%' OR table_name ILIKE '%auth%' OR table_name ILIKE '%login%')
            ORDER BY table_schema, table_name
        """)
        user_tables = cursor.fetchall()
        
        for schema, table in user_tables:
            print(f"  - {schema}.{table}")

        # Ищем все таблицы в схеме public
        print("\n🔍 Все таблицы в схеме public:")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            ORDER BY table_name
        """)
        public_tables = cursor.fetchall()
        
        for table in public_tables:
            table_name = table[0]
            print(f"  - {table_name}")

        # Проверяем каждую таблицу на наличие полей, связанных с пользователями
        print("\n🔍 Поиск полей, связанных с пользователями:")
        for table in public_tables:
            table_name = table[0]
            
            # Проверяем структуру каждой таблицы на наличие полей, связанных с пользователями
            cursor.execute("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_schema = 'public' AND table_name = %s
                AND (column_name ILIKE '%%user%%' OR column_name ILIKE '%%email%%' OR 
                     column_name ILIKE '%%password%%' OR column_name ILIKE '%%login%%' OR
                     column_name ILIKE '%%username%%' OR column_name ILIKE '%%auth%%')
                ORDER BY ordinal_position
            """, (table_name,))
            
            user_columns = cursor.fetchall()
            if user_columns:
                print(f"  📋 Таблица {table_name}:")
                for col in user_columns:
                    print(f"    - {col[0]}: {col[1]}")

        # Проверяем конкретно таблицу profile более детально
        print(f"\n🔍 Детальная проверка таблицы profile:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'profile'
            ORDER BY ordinal_position
        """)
        profile_columns = cursor.fetchall()
        
        if profile_columns:
            print(f"  📋 Структура таблицы profile:")
            for col in profile_columns:
                default = col[3] if col[3] else 'NULL'
                print(f"    - {col[0]}: {col[1]} (nullable: {col[2]}, default: {default})")
            
            # Проверяем данные в profile
            cursor.execute("SELECT * FROM profile")
            profile_data = cursor.fetchall()
            print(f"  📄 Данные в profile: {profile_data}")

        # Ищем таблицы с полями email или username
        print(f"\n🔍 Поиск таблиц с полями email или username:")
        cursor.execute("""
            SELECT DISTINCT table_name 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND (column_name = 'email' OR column_name = 'username')
            ORDER BY table_name
        """)
        email_username_tables = cursor.fetchall()
        
        for table in email_username_tables:
            table_name = table[0]
            print(f"  - {table_name}")
            
            # Показываем структуру этих таблиц
            cursor.execute("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns 
                WHERE table_schema = 'public' AND table_name = %s
                ORDER BY ordinal_position
            """, (table_name,))
            
            columns = cursor.fetchall()
            print(f"    📋 Структура:")
            for col in columns:
                print(f"      - {col[0]}: {col[1]} (nullable: {col[2]})")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Поиск завершен")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = find_user_tables()
    
    if not success:
        print("\n❌ Не удалось выполнить поиск")

if __name__ == "__main__":
    main()
