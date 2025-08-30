#!/usr/bin/env python3
"""
Исправление таблицы profile - добавление недостающих колонок
"""
import psycopg2

# Конфигурация серверной базы данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def fix_profile_table():
    """Исправление таблицы profile"""
    print("🔧 ИСПРАВЛЕНИЕ ТАБЛИЦЫ PROFILE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем текущую структуру таблицы profile
        print("\n📋 Проверка текущей структуры таблицы profile...")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'profile' 
            ORDER BY ordinal_position
        """)
        columns = cursor.fetchall()
        
        print("📊 Текущие колонки:")
        for col in columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]})")
        
        # Добавляем недостающие колонки
        print("\n🔧 Добавление недостающих колонок...")
        
        # Список колонок, которые нужно добавить
        missing_columns = [
            ("avatar_url", "VARCHAR(500)", "NULL"),
            ("bio", "TEXT", "NULL"),
            ("phone", "VARCHAR(20)", "NULL"),
            ("birth_date", "DATE", "NULL"),
            ("gender", "VARCHAR(10)", "NULL"),
            ("location", "VARCHAR(255)", "NULL"),
            ("website", "VARCHAR(255)", "NULL"),
            ("social_links", "JSONB", "NULL"),
            ("preferences", "JSONB", "NULL"),
            ("settings", "JSONB", "NULL")
        ]
        
        existing_columns = [col[0] for col in columns]
        
        for col_name, col_type, nullable in missing_columns:
            if col_name not in existing_columns:
                try:
                    sql = f'ALTER TABLE profile ADD COLUMN {col_name} {col_type} {nullable}'
                    cursor.execute(sql)
                    print(f"  ✅ Добавлена колонка {col_name}")
                except Exception as e:
                    print(f"  ❌ Ошибка добавления колонки {col_name}: {e}")
            else:
                print(f"  ⚠️ Колонка {col_name} уже существует")
        
        # Проверяем результат
        print("\n📋 Проверка обновленной структуры...")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'profile' 
            ORDER BY ordinal_position
        """)
        updated_columns = cursor.fetchall()
        
        print("📊 Обновленные колонки:")
        for col in updated_columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]})")
        
        cursor.close()
        conn.close()
        print("\n✅ Структура таблицы profile исправлена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_profile_table()
