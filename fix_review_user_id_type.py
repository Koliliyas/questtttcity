#!/usr/bin/env python3
"""
Исправление типа user_id в таблице review с INTEGER на UUID
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

def fix_review_user_id_type():
    """Исправление типа user_id в таблице review"""
    print("🔧 ИСПРАВЛЕНИЕ ТИПА USER_ID В ТАБЛИЦЕ REVIEW")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Исправление таблицы review...")
        
        # Проверяем текущий тип user_id
        cursor.execute("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'review' AND column_name = 'user_id'
        """)
        column_info = cursor.fetchone()
        
        if column_info and column_info[1] == 'integer':
            print(f"  📋 Текущий тип user_id: {column_info[1]}")
            
            # Изменяем тип user_id на UUID
            cursor.execute("ALTER TABLE review ALTER COLUMN user_id TYPE UUID USING user_id::uuid")
            print("  ✅ Тип user_id изменен на UUID")
            
            # Добавляем внешний ключ
            cursor.execute("ALTER TABLE review ADD CONSTRAINT fk_review_user_id FOREIGN KEY (user_id) REFERENCES \"user\"(id) ON DELETE CASCADE")
            print("  ✅ Внешний ключ добавлен")
            
        else:
            print("  ✅ user_id уже имеет правильный тип")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_review_user_id_type()
