#!/usr/bin/env python3
"""
Полное пересоздание проблемных таблиц с правильными типами
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

def rebuild_problem_tables():
    """Полное пересоздание проблемных таблиц"""
    print("🔧 ПОЛНОЕ ПЕРЕСОЗДАНИЕ ПРОБЛЕМНЫХ ТАБЛИЦ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Пересоздаем таблицу review_response
        print("\n🔧 Пересоздание таблицы review_response...")
        cursor.execute("DROP TABLE IF EXISTS review_response")
        cursor.execute("""
            CREATE TABLE review_response (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                text TEXT NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                user_id UUID REFERENCES "user"(id) ON DELETE CASCADE
            )
        """)
        print("  ✅ Таблица review_response пересоздана")
        
        # Пересоздаем таблицу review
        print("\n🔧 Пересоздание таблицы review...")
        cursor.execute("DROP TABLE IF EXISTS review")
        cursor.execute("""
            CREATE TABLE review (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                rating INTEGER NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                quest_id INTEGER NOT NULL,
                text TEXT NOT NULL,
                user_id UUID REFERENCES "user"(id) ON DELETE CASCADE
            )
        """)
        print("  ✅ Таблица review пересоздана")
        
        cursor.close()
        conn.close()
        print("\n✅ Пересоздание завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    rebuild_problem_tables()
