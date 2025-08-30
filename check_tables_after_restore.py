#!/usr/bin/env python3
"""
Проверка таблиц после восстановления из бэкапа
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

def check_tables():
    """Проверяет какие таблицы есть в базе данных"""
    print("🔧 ПРОВЕРКА ТАБЛИЦ ПОСЛЕ ВОССТАНОВЛЕНИЯ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Получаем список всех таблиц
        cursor.execute("""
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'public'
            ORDER BY tablename
        """)
        
        tables = [row[0] for row in cursor.fetchall()]
        print(f"\n📋 Найдено таблиц: {len(tables)}")
        
        for table in tables:
            print(f"  ✅ {table}")
        
        # Проверяем таблицу user отдельно
        print("\n🔍 Проверка таблицы user:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'user'
            ORDER BY ordinal_position
        """)
        
        columns = cursor.fetchall()
        if columns:
            print(f"  ✅ Таблица user существует с {len(columns)} колонками:")
            for col in columns:
                print(f"    - {col[0]} ({col[1]}, nullable: {col[2]})")
        else:
            print("  ❌ Таблица user НЕ существует!")
        
        # Проверяем данные в таблице user
        if columns:
            print("\n📊 Данные в таблице user:")
            cursor.execute("SELECT id, email, username FROM \"user\" LIMIT 5")
            users = cursor.fetchall()
            for user in users:
                print(f"  - ID: {user[0]}, Email: {user[1]}, Username: {user[2]}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_tables()
