#!/usr/bin/env python3
"""
Удаление колонки owner_id из таблицы review
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

def remove_owner_id_column():
    """Удаление колонки owner_id из таблицы review"""
    print("🔧 УДАЛЕНИЕ КОЛОНКИ OWNER_ID ИЗ ТАБЛИЦЫ REVIEW")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Удаление колонки owner_id...")
        
        # Удаляем колонку owner_id
        cursor.execute("ALTER TABLE review DROP COLUMN owner_id")
        print("  ✅ Колонка owner_id удалена")
        
        cursor.close()
        conn.close()
        print("\n✅ Удаление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    remove_owner_id_column()
