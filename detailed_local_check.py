#!/usr/bin/env python3
"""
Детальная проверка локальной базы данных
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

def detailed_local_check():
    """Детальная проверка локальной базы данных"""
    print("🔍 Детальная проверка локальной базы данных")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к локальной базе
        print("🔗 Подключение к локальной базе данных...")
        conn = psycopg2.connect(**LOCAL_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к локальной базе успешно!")

        # Проверяем все схемы
        print("\n📋 Проверка схем:")
        cursor.execute("""
            SELECT schema_name 
            FROM information_schema.schemata 
            ORDER BY schema_name
        """)
        schemas = cursor.fetchall()
        for schema in schemas:
            print(f"  - {schema[0]}")

        # Получаем список всех таблиц во всех схемах
        print("\n📋 Все таблицы во всех схемах:")
        cursor.execute("""
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_type = 'BASE TABLE'
            ORDER BY table_schema, table_name
        """)
        all_tables = cursor.fetchall()
        
        for schema, table in all_tables:
            print(f"  - {schema}.{table}")

        # Проверяем конкретно таблицы в схеме public
        print("\n📋 Таблицы в схеме public:")
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
            
            # Проверяем количество записей в каждой таблице
            try:
                cursor.execute(f"SELECT COUNT(*) FROM public.{table_name}")
                count = cursor.fetchone()[0]
                print(f"    📊 Записей: {count}")
            except Exception as e:
                print(f"    ❌ Ошибка подсчета: {e}")

        # Проверяем конкретные таблицы, которые нам нужны
        important_tables = ['user', 'profile', 'point', 'quest', 'category', 'vehicle', 'place', 'activity', 'tool', 'place_settings']
        
        print(f"\n🔍 Детальная проверка важных таблиц:")
        for table_name in important_tables:
            print(f"\n📍 Проверка таблицы: {table_name}")
            
            # Проверяем существование таблицы
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = %s
                )
            """, (table_name,))
            
            exists = cursor.fetchone()[0]
            if exists:
                print(f"  ✅ Таблица {table_name} существует")
                
                # Проверяем структуру
                cursor.execute("""
                    SELECT column_name, data_type, is_nullable, column_default
                    FROM information_schema.columns 
                    WHERE table_schema = 'public' AND table_name = %s
                    ORDER BY ordinal_position
                """, (table_name,))
                
                columns = cursor.fetchall()
                print(f"  📋 Структура таблицы {table_name}:")
                for col in columns:
                    default = col[3] if col[3] else 'NULL'
                    print(f"    - {col[0]}: {col[1]} (nullable: {col[2]}, default: {default})")
                
                # Проверяем данные
                try:
                    cursor.execute(f"SELECT COUNT(*) FROM public.{table_name}")
                    count = cursor.fetchone()[0]
                    print(f"  📊 Количество записей: {count}")
                    
                    if count > 0:
                        cursor.execute(f"SELECT * FROM public.{table_name} LIMIT 2")
                        rows = cursor.fetchall()
                        print(f"  📄 Примеры данных: {rows}")
                        
                except Exception as e:
                    print(f"  ❌ Ошибка при проверке данных: {e}")
            else:
                print(f"  ❌ Таблица {table_name} НЕ существует")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Детальная проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = detailed_local_check()
    
    if not success:
        print("\n❌ Не удалось проверить локальную базу данных")

if __name__ == "__main__":
    main()
