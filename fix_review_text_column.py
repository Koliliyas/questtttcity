#!/usr/bin/env python3
"""
Исправление колонки text в таблице review
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

def fix_review_text_column():
    """Исправление колонки text в таблице review"""
    print("🔧 ИСПРАВЛЕНИЕ КОЛОНКИ TEXT В ТАБЛИЦЕ REVIEW")
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
            AND column_name IN ('text', 'review')
            ORDER BY ordinal_position
        """)
        columns = cursor.fetchall()
        
        print("📊 Текущие колонки text/review:")
        for col in columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]})")
        
        # Проверяем, есть ли колонка text
        has_text = any(col[0] == 'text' for col in columns)
        has_review = any(col[0] == 'review' for col in columns)
        
        if has_text:
            print("  ✅ Колонка text уже существует")
        elif has_review:
            print("  🔧 Переименование review в text...")
            try:
                cursor.execute('ALTER TABLE review RENAME COLUMN review TO text')
                print("  ✅ Колонка переименована")
            except Exception as e:
                print(f"  ❌ Ошибка переименования: {e}")
        else:
            print("  ❌ Ни одна из колонок text/review не найдена")
        
        cursor.close()
        conn.close()
        print("\n✅ Колонка text исправлена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_review_text_column()
