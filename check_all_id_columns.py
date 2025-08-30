#!/usr/bin/env python3
"""
Проверка всех колонок id в базе данных
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

def check_all_id_columns():
    """Проверка всех колонок id"""
    print("🔍 ПРОВЕРКА ВСЕХ КОЛОНОК ID")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем все колонки id
        cursor.execute("""
            SELECT table_name, column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE column_name = 'id' AND table_schema = 'public'
            ORDER BY table_name
        """)
        id_columns = cursor.fetchall()
        
        print("📊 Все колонки id:")
        for col in id_columns:
            print(f"  - {col[0]}.{col[1]}: {col[2]} (nullable: {col[3]}, default: {col[4]})")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_all_id_columns()
