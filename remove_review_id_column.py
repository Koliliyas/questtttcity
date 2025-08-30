#!/usr/bin/env python3
"""
Удаление колонки review_id из таблицы review_response
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

def remove_review_id_column():
    """Удаление колонки review_id из таблицы review_response"""
    print("🔧 УДАЛЕНИЕ КОЛОНКИ REVIEW_ID ИЗ ТАБЛИЦЫ REVIEW_RESPONSE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Удаление колонки review_id...")
        
        # Удаляем колонку review_id
        cursor.execute("ALTER TABLE review_response DROP COLUMN review_id")
        print("  ✅ Колонка review_id удалена")
        
        cursor.close()
        conn.close()
        print("\n✅ Удаление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    remove_review_id_column()
