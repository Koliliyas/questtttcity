#!/usr/bin/env python3
"""
Восстановление исходной структуры базы данных
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

def restore_original_database():
    """Восстановление исходной структуры базы данных"""
    print("🔧 ВОССТАНОВЛЕНИЕ ИСХОДНОЙ СТРУКТУРЫ БАЗЫ ДАННЫХ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Восстанавливаем таблицу review_response к исходному состоянию
        print("\n🔧 Восстановление таблицы review_response...")
        cursor.execute("DROP TABLE IF EXISTS review_response")
        cursor.execute("""
            CREATE TABLE review_response (
                id SERIAL PRIMARY KEY,
                text TEXT NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                review_id INTEGER,
                user_id INTEGER
            )
        """)
        print("  ✅ Таблица review_response восстановлена")
        
        # Восстанавливаем таблицу review к исходному состоянию
        print("\n🔧 Восстановление таблицы review...")
        cursor.execute("DROP TABLE IF EXISTS review")
        cursor.execute("""
            CREATE TABLE review (
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
        print("  ✅ Таблица review восстановлена")
        
        # Восстанавливаем таблицы токенов к исходному состоянию
        print("\n🔧 Восстановление таблиц токенов...")
        
        # refresh_token
        cursor.execute("DROP TABLE IF EXISTS refresh_token")
        cursor.execute("""
            CREATE TABLE refresh_token (
                id SERIAL PRIMARY KEY,
                token VARCHAR(255) NOT NULL,
                user_id INTEGER NOT NULL,
                expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица refresh_token восстановлена")
        
        # reset_password_token
        cursor.execute("DROP TABLE IF EXISTS reset_password_token")
        cursor.execute("""
            CREATE TABLE reset_password_token (
                id SERIAL PRIMARY KEY,
                token VARCHAR(255) NOT NULL,
                user_id INTEGER NOT NULL,
                expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица reset_password_token восстановлена")
        
        # email_verification_code
        cursor.execute("DROP TABLE IF EXISTS email_verification_code")
        cursor.execute("""
            CREATE TABLE email_verification_code (
                code INTEGER NOT NULL,
                email VARCHAR(30) NOT NULL,
                optional_data JSON,
                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL,
                CONSTRAINT pk_email_verification_code PRIMARY KEY (code, email)
            )
        """)
        print("  ✅ Таблица email_verification_code восстановлена")
        
        cursor.close()
        conn.close()
        print("\n✅ Восстановление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    restore_original_database()
