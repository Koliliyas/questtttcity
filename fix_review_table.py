#!/usr/bin/env python3
"""
Исправление таблицы review - добавление первичного ключа
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

def fix_review_table():
    """Исправление таблицы review"""
    print("🔧 ИСПРАВЛЕНИЕ ТАБЛИЦЫ REVIEW")
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
        
        # Проверяем первичный ключ
        cursor.execute("""
            SELECT constraint_name 
            FROM information_schema.table_constraints 
            WHERE table_name = 'review' 
            AND constraint_type = 'PRIMARY KEY'
        """)
        pk = cursor.fetchone()
        
        if pk:
            print(f"  ✅ Первичный ключ уже существует: {pk[0]}")
        else:
            print("  ❌ Первичный ключ отсутствует")
            
            # Добавляем первичный ключ
            print("\n🔧 Добавление первичного ключа...")
            try:
                cursor.execute("ALTER TABLE review ADD PRIMARY KEY (id)")
                print("  ✅ Первичный ключ добавлен")
            except Exception as e:
                print(f"  ❌ Ошибка добавления первичного ключа: {e}")
        
        cursor.close()
        conn.close()
        print("\n✅ Таблица review исправлена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_review_table()
