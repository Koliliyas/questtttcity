#!/usr/bin/env python3
"""
Исправление типа id в таблице review_response с INTEGER на UUID
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

def fix_review_response_id():
    """Исправление типа id в таблице review_response"""
    print("🔧 ИСПРАВЛЕНИЕ ТИПА ID В ТАБЛИЦЕ REVIEW_RESPONSE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Исправление таблицы review_response...")
        
        # Проверяем текущий тип id
        cursor.execute("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'review_response' AND column_name = 'id'
        """)
        column_info = cursor.fetchone()
        
        if column_info and column_info[1] == 'integer':
            print(f"  📋 Текущий тип id: {column_info[1]}")
            
            # Получаем структуру таблицы
            cursor.execute("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'review_response'
                ORDER BY ordinal_position
            """)
            columns = cursor.fetchall()
            
            # Создаем новую структуру с UUID id
            create_columns = []
            for col in columns:
                if col[0] == 'id':
                    create_columns.append('id UUID PRIMARY KEY DEFAULT gen_random_uuid()')
                else:
                    nullable = "NOT NULL" if col[2] == "NO" else ""
                    default = f"DEFAULT {col[3]}" if col[3] else ""
                    create_columns.append(f"{col[0]} {col[1]} {nullable} {default}".strip())
            
            # Пересоздаем таблицу
            cursor.execute("DROP TABLE review_response")
            cursor.execute(f"CREATE TABLE review_response ({', '.join(create_columns)})")
            
            print("  ✅ Таблица review_response исправлена")
        else:
            print("  ✅ Таблица review_response уже имеет правильный тип id")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_review_response_id()
