#!/usr/bin/env python3
"""
Проверка таблицы profile
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

def check_profile_table():
    """Проверяет таблицу profile"""
    print("🔧 ПРОВЕРКА ТАБЛИЦЫ PROFILE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем структуру таблицы profile
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'profile'
            ORDER BY ordinal_position
        """)
        
        columns = cursor.fetchall()
        print(f"\n📋 Структура таблицы profile:")
        for col in columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем первичный ключ
        cursor.execute("""
            SELECT constraint_name, constraint_type
            FROM information_schema.table_constraints
            WHERE table_name = 'profile' AND constraint_type = 'PRIMARY KEY'
        """)
        
        pk = cursor.fetchall()
        print(f"\n🔑 Первичные ключи:")
        for key in pk:
            print(f"  - {key[0]} ({key[1]})")
        
        # Проверяем данные
        cursor.execute("SELECT * FROM profile LIMIT 5")
        profiles = cursor.fetchall()
        print(f"\n📊 Данные в таблице profile:")
        for profile in profiles:
            print(f"  - {profile}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_profile_table()
