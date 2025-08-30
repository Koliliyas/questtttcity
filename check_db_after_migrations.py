#!/usr/bin/env python3
"""
Проверка базы данных после применения миграций
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

def check_db_after_migrations():
    """Проверка базы данных после применения миграций"""
    print("🔍 ПРОВЕРКА БАЗЫ ДАННЫХ ПОСЛЕ МИГРАЦИЙ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем таблицу alembic_version
        print("\n📋 Проверка таблицы alembic_version:")
        cursor.execute("SELECT version_num FROM alembic_version")
        version = cursor.fetchone()
        if version:
            print(f"  📊 Текущая версия: {version[0]}")
        else:
            print("  ❌ Версия не найдена")
        
        # Проверяем все таблицы
        print("\n📋 Все таблицы в базе данных:")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        """)
        tables = cursor.fetchall()
        
        print("📊 Найдены таблицы:")
        for table in tables:
            print(f"  - {table[0]}")
        
        # Проверяем структуру таблицы user
        print("\n📋 Структура таблицы user:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'user' 
            ORDER BY ordinal_position
        """)
        user_columns = cursor.fetchall()
        
        for col in user_columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем структуру таблицы profile
        print("\n📋 Структура таблицы profile:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'profile' 
            ORDER BY ordinal_position
        """)
        profile_columns = cursor.fetchall()
        
        for col in profile_columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем данные в таблице user
        print("\n📋 Данные в таблице user:")
        cursor.execute('SELECT id, email, username, password FROM "user"')
        users = cursor.fetchall()
        print(f"  📊 Количество записей: {len(users)}")
        for user in users:
            print(f"    - ID: {user[0]} | Email: {user[1]} | Username: {user[2]} | Password: {user[3][:20]}...")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_db_after_migrations()
