#!/usr/bin/env python3
"""
Исправление типа review_id в таблице review_response с INTEGER на UUID
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

def fix_review_response_review_id():
    """Исправление типа review_id в таблице review_response"""
    print("🔧 ИСПРАВЛЕНИЕ ТИПА REVIEW_ID В ТАБЛИЦЕ REVIEW_RESPONSE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Исправление таблицы review_response...")
        
        # Проверяем текущий тип review_id
        cursor.execute("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'review_response' AND column_name = 'review_id'
        """)
        column_info = cursor.fetchone()
        
        if column_info and column_info[1] == 'integer':
            print(f"  📋 Текущий тип review_id: {column_info[1]}")
            
            # Изменяем тип review_id на UUID
            cursor.execute("ALTER TABLE review_response ALTER COLUMN review_id TYPE UUID USING review_id::uuid")
            print("  ✅ Тип review_id изменен на UUID")
            
            # Добавляем внешний ключ
            cursor.execute("ALTER TABLE review_response ADD CONSTRAINT fk_review_response_review_id FOREIGN KEY (review_id) REFERENCES review(id) ON DELETE CASCADE")
            print("  ✅ Внешний ключ добавлен")
            
        else:
            print("  ✅ review_id уже имеет правильный тип")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_review_response_review_id()
