#!/usr/bin/env python3
"""
Исправление типов user_id в таблицах токенов
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

def fix_token_user_id_types():
    """Исправление типов user_id в таблицах токенов"""
    print("🔧 ИСПРАВЛЕНИЕ ТИПОВ USER_ID В ТАБЛИЦАХ ТОКЕНОВ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Исправляем refresh_token
        print("\n🔧 Исправление refresh_token...")
        cursor.execute("ALTER TABLE refresh_token ALTER COLUMN user_id TYPE UUID USING user_id::uuid")
        print("  ✅ user_id в refresh_token изменен на UUID")
        
        # Исправляем reset_password_token
        print("\n🔧 Исправление reset_password_token...")
        cursor.execute("ALTER TABLE reset_password_token ALTER COLUMN user_id TYPE UUID USING user_id::uuid")
        print("  ✅ user_id в reset_password_token изменен на UUID")
        
        # Исправляем review
        print("\n🔧 Исправление review...")
        cursor.execute("ALTER TABLE review ALTER COLUMN user_id TYPE UUID USING user_id::uuid")
        cursor.execute("ALTER TABLE review ALTER COLUMN owner_id TYPE UUID USING owner_id::uuid")
        print("  ✅ user_id и owner_id в review изменены на UUID")
        
        # Исправляем review_response
        print("\n🔧 Исправление review_response...")
        cursor.execute("ALTER TABLE review_response ALTER COLUMN user_id TYPE UUID USING user_id::uuid")
        print("  ✅ user_id в review_response изменен на UUID")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_token_user_id_types()
