#!/usr/bin/env python3
"""
Добавление колонки user_id в таблицу review
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

def fix_review_user_id():
    """Добавление колонки user_id в таблицу review"""
    print("🔧 ДОБАВЛЕНИЕ КОЛОНКИ USER_ID В ТАБЛИЦУ REVIEW")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем текущую структуру таблицы review
        print("\n📋 Проверка текущей структуры таблицы review...")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'review' 
            ORDER BY ordinal_position
        """)
        columns = cursor.fetchall()
        
        print("📊 Текущие колонки:")
        for col in columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]})")
        
        # Проверяем, есть ли колонка user_id
        has_user_id = any(col[0] == 'user_id' for col in columns)
        
        if has_user_id:
            print("  ✅ Колонка user_id уже существует")
        else:
            print("  🔧 Добавление колонки user_id...")
            try:
                cursor.execute('ALTER TABLE review ADD COLUMN user_id UUID REFERENCES "user"(id) ON DELETE CASCADE')
                print("  ✅ Колонка user_id добавлена")
                
                # Обновляем существующие записи, устанавливая user_id = owner_id
                print("  🔧 Обновление существующих записей...")
                cursor.execute('UPDATE review SET user_id = owner_id::uuid')
                print("  ✅ Существующие записи обновлены")
                
            except Exception as e:
                print(f"  ❌ Ошибка добавления колонки user_id: {e}")
        
        cursor.close()
        conn.close()
        print("\n✅ Колонка user_id исправлена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_review_user_id()
