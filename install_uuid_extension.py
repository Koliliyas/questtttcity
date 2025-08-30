#!/usr/bin/env python3
"""
Установка расширения uuid-ossp
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

def install_uuid_extension():
    """Установка расширения uuid-ossp"""
    print("🔧 УСТАНОВКА РАСШИРЕНИЯ UUID-OSSP")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("\n🔧 Установка расширения uuid-ossp...")
        cursor.execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")
        print("  ✅ Расширение uuid-ossp установлено")
        
        cursor.close()
        conn.close()
        print("\n✅ Установка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    install_uuid_extension()
