#!/usr/bin/env python3
"""
Проверка всех колонок с типом UUID
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

def check_uuid_columns():
    """Проверка всех колонок с типом UUID"""
    print("🔍 ПРОВЕРКА ВСЕХ КОЛОНОК С ТИПОМ UUID")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем все колонки с типом UUID
        print("\n📋 Все колонки с типом UUID:")
        cursor.execute("""
            SELECT table_name, column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE data_type = 'uuid'
            ORDER BY table_name, column_name
        """)
        uuid_columns = cursor.fetchall()
        
        if uuid_columns:
            for col in uuid_columns:
                print(f"  - {col[0]}.{col[1]}: {col[2]} (nullable: {col[3]})")
        else:
            print("  📊 Колонок с типом UUID не найдено")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_uuid_columns()
