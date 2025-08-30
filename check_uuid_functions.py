#!/usr/bin/env python3
"""
Проверка UUID функций в базе данных
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

def check_uuid_functions():
    """Проверка UUID функций в базе данных"""
    print("🔍 ПРОВЕРКА UUID ФУНКЦИЙ В БАЗЕ ДАННЫХ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем, есть ли расширение uuid-ossp
        print("\n📋 Проверка расширения uuid-ossp...")
        cursor.execute("SELECT * FROM pg_extension WHERE extname = 'uuid-ossp'")
        uuid_extension = cursor.fetchone()
        
        if uuid_extension:
            print("  ✅ Расширение uuid-ossp установлено")
        else:
            print("  ❌ Расширение uuid-ossp не установлено")
        
        # Проверяем функции для работы с UUID
        print("\n📋 Проверка UUID функций...")
        cursor.execute("""
            SELECT proname, prosrc 
            FROM pg_proc 
            WHERE proname IN ('gen_random_uuid', 'uuid_generate_v4')
        """)
        uuid_functions = cursor.fetchall()
        
        if uuid_functions:
            for func in uuid_functions:
                print(f"  - {func[0]}: {func[1]}")
        else:
            print("  📊 UUID функции не найдены")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_uuid_functions()
