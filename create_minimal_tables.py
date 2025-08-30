#!/usr/bin/env python3
"""
Создание минимально необходимых таблиц
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

def create_minimal_tables():
    """Создание минимально необходимых таблиц"""
    print("🔧 СОЗДАНИЕ МИНИМАЛЬНО НЕОБХОДИМЫХ ТАБЛИЦ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Создаем таблицу review_response
        print("\n🔧 Создание таблицы review_response...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS review_response (
                id SERIAL PRIMARY KEY,
                text TEXT NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                review_id INTEGER,
                user_id INTEGER
            )
        """)
        print("  ✅ Таблица review_response создана")
        
        # Создаем таблицу review
        print("\n🔧 Создание таблицы review...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS review (
                id SERIAL PRIMARY KEY,
                rating INTEGER NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                quest_id INTEGER NOT NULL,
                text TEXT NOT NULL,
                owner_id INTEGER NOT NULL,
                user_id INTEGER
            )
        """)
        print("  ✅ Таблица review создана")
        
        # Создаем таблицу refresh_token
        print("\n🔧 Создание таблицы refresh_token...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS refresh_token (
                id SERIAL PRIMARY KEY,
                token VARCHAR(255) NOT NULL,
                user_id INTEGER NOT NULL,
                expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица refresh_token создана")
        
        # Создаем таблицу reset_password_token
        print("\n🔧 Создание таблицы reset_password_token...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS reset_password_token (
                id SERIAL PRIMARY KEY,
                token VARCHAR(255) NOT NULL,
                user_id INTEGER NOT NULL,
                expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица reset_password_token создана")
        
        # Создаем таблицу email_verification_code
        print("\n🔧 Создание таблицы email_verification_code...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS email_verification_code (
                code INTEGER NOT NULL,
                email VARCHAR(30) NOT NULL,
                optional_data JSON,
                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL,
                CONSTRAINT pk_email_verification_code PRIMARY KEY (code, email)
            )
        """)
        print("  ✅ Таблица email_verification_code создана")
        
        cursor.close()
        conn.close()
        print("\n✅ Создание завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    create_minimal_tables()
