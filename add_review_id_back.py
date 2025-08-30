#!/usr/bin/env python3
"""
Добавление колонки review_id обратно в таблицу review_response
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

def add_review_id_back():
    """Добавление колонки review_id обратно"""
    print("🔧 ДОБАВЛЕНИЕ КОЛОНКИ REVIEW_ID ОБРАТНО")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Добавление колонки review_id...")
        
        # Добавляем колонку review_id обратно
        cursor.execute("ALTER TABLE review_response ADD COLUMN review_id UUID")
        print("  ✅ Колонка review_id добавлена")
        
        cursor.close()
        conn.close()
        print("\n✅ Добавление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    add_review_id_back()
