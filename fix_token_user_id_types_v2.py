#!/usr/bin/env python3
"""
Исправление типов user_id в таблицах токенов (версия 2)
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

def fix_token_user_id_types_v2():
    """Исправление типов user_id в таблицах токенов"""
    print("🔧 ИСПРАВЛЕНИЕ ТИПОВ USER_ID В ТАБЛИЦАХ ТОКЕНОВ (ВЕРСИЯ 2)")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Очищаем таблицы и пересоздаем их с правильными типами
        print("\n🔧 Пересоздание таблиц с правильными типами...")
        
        # refresh_token
        cursor.execute("DROP TABLE IF EXISTS refresh_token")
        cursor.execute("""
            CREATE TABLE refresh_token (
                id SERIAL PRIMARY KEY,
                token VARCHAR(255) NOT NULL,
                user_id UUID NOT NULL,
                expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица refresh_token пересоздана с UUID user_id")
        
        # reset_password_token
        cursor.execute("DROP TABLE IF EXISTS reset_password_token")
        cursor.execute("""
            CREATE TABLE reset_password_token (
                id SERIAL PRIMARY KEY,
                token VARCHAR(255) NOT NULL,
                user_id UUID NOT NULL,
                expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица reset_password_token пересоздана с UUID user_id")
        
        # review
        cursor.execute("DROP TABLE IF EXISTS review")
        cursor.execute("""
            CREATE TABLE review (
                id SERIAL PRIMARY KEY,
                rating INTEGER NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                quest_id INTEGER NOT NULL,
                text TEXT NOT NULL,
                owner_id UUID NOT NULL,
                user_id UUID
            )
        """)
        print("  ✅ Таблица review пересоздана с UUID user_id и owner_id")
        
        # review_response
        cursor.execute("DROP TABLE IF EXISTS review_response")
        cursor.execute("""
            CREATE TABLE review_response (
                id SERIAL PRIMARY KEY,
                text TEXT NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                review_id INTEGER,
                user_id UUID
            )
        """)
        print("  ✅ Таблица review_response пересоздана с UUID user_id")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_token_user_id_types_v2()
