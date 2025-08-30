#!/usr/bin/env python3
"""
Исправление последней проблемы с nullable в review
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

def fix_final_issue():
    """Исправление последней проблемы"""
    print("🔧 ИСПРАВЛЕНИЕ ПОСЛЕДНЕЙ ПРОБЛЕМЫ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Исправляем nullable для owner_id в review
        print("\n🔧 Исправление nullable для owner_id в review...")
        cursor.execute("ALTER TABLE review ALTER COLUMN owner_id SET NOT NULL")
        print("  ✅ owner_id сделан NOT NULL")
        
        cursor.close()
        conn.close()
        print("\n✅ Последняя проблема исправлена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_final_issue()
