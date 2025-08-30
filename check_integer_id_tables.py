#!/usr/bin/env python3
"""
Проверка таблиц с INTEGER id
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

def check_integer_id_tables():
    """Проверка таблиц с INTEGER id"""
    print("🔍 ПРОВЕРКА ТАБЛИЦ С INTEGER ID")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем все таблицы с колонкой id
        print("\n📋 Все таблицы с колонкой id:")
        cursor.execute("""
            SELECT table_name, column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE column_name = 'id'
            ORDER BY table_name
        """)
        columns = cursor.fetchall()
        
        for col in columns:
            print(f"  - {col[0]}.{col[1]}: {col[2]} (nullable: {col[3]})")
        
        # Проверяем таблицы с INTEGER id
        print("\n📋 Таблицы с INTEGER id:")
        cursor.execute("""
            SELECT table_name, column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE column_name = 'id' AND data_type = 'integer'
            ORDER BY table_name
        """)
        integer_columns = cursor.fetchall()
        
        for col in integer_columns:
            print(f"  - {col[0]}.{col[1]}: {col[2]} (nullable: {col[3]})")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_integer_id_tables()
