#!/usr/bin/env python3
"""
Переименование hashed_password в password
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

def fix_password_column():
    """Переименование hashed_password в password"""
    print("🔧 ПЕРЕИМЕНОВАНИЕ HASHED_PASSWORD В PASSWORD")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("\n🔧 Переименование колонки...")
        cursor.execute('ALTER TABLE "user" RENAME COLUMN hashed_password TO password')
        print("  ✅ Колонка hashed_password переименована в password")
        
        cursor.close()
        conn.close()
        print("\n✅ Переименование завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_password_column()
