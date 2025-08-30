#!/usr/bin/env python3
"""
Детальная проверка структуры таблицы user
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

def check_user_table_detailed():
    """Детальная проверка структуры таблицы user"""
    print("🔍 ДЕТАЛЬНАЯ ПРОВЕРКА ТАБЛИЦЫ USER")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем структуру таблицы user
        print("\n📋 Структура таблицы user:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'user' 
            ORDER BY ordinal_position
        """)
        columns = cursor.fetchall()
        
        print("📊 Колонки:")
        for col in columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем первичный ключ
        print("\n📋 Первичный ключ:")
        cursor.execute("""
            SELECT constraint_name, constraint_type
            FROM information_schema.table_constraints 
            WHERE table_name = 'user' AND constraint_type = 'PRIMARY KEY'
        """)
        pk = cursor.fetchone()
        if pk:
            print(f"  - {pk[0]} ({pk[1]})")
        else:
            print("  - Первичный ключ не найден")
        
        # Проверяем данные
        print("\n📋 Данные в таблице:")
        cursor.execute('SELECT id, email, username, password FROM "user"')
        users = cursor.fetchall()
        print(f"  📊 Количество записей: {len(users)}")
        for user in users:
            print(f"    - ID: {user[0]} | Email: {user[1]} | Username: {user[2]} | Password: {user[3][:20]}...")
        
        # Проверяем админа отдельно
        print("\n📋 Проверка админа:")
        cursor.execute('SELECT id, email, username, password, role FROM "user" WHERE email = %s', ("admin@questcity.com",))
        admin = cursor.fetchone()
        if admin:
            print(f"  ✅ Админ найден: ID={admin[0]}, Email={admin[1]}, Username={admin[2]}, Role={admin[4]}")
        else:
            print("  ❌ Админ не найден")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_user_table_detailed()
