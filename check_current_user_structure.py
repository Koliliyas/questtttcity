#!/usr/bin/env python3
"""
Проверка текущей структуры таблицы user
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

def check_current_user_structure():
    """Проверка текущей структуры таблицы user"""
    print("🔍 ПРОВЕРКА ТЕКУЩЕЙ СТРУКТУРЫ ТАБЛИЦЫ USER")
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
        
        for col in columns:
            print(f"  - {col[0]}: {col[1]} (nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем данные в таблице user
        print("\n📋 Данные в таблице user:")
        cursor.execute('SELECT id, email, username, hashed_password FROM "user"')
        users = cursor.fetchall()
        
        print(f"  📊 Количество пользователей: {len(users)}")
        for user in users:
            print(f"    - ID: {user[0]} | Email: {user[1]} | Username: {user[2]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_current_user_structure()
