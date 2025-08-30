#!/usr/bin/env python3
"""
Удаление таблицы user (зарезервированное слово)
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

def remove_user_table():
    """Удаление таблицы user"""
    print("🗑️ УДАЛЕНИЕ ТАБЛИЦЫ USER")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем существование таблицы user
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'user'
            )
        """)
        
        table_exists = cursor.fetchone()[0]
        
        if table_exists:
            # Удаляем таблицу user с кавычками (зарезервированное слово)
            cursor.execute('DROP TABLE IF EXISTS "user" CASCADE')
            print("  ✅ Таблица user удалена")
        else:
            print("  ⚠️ Таблица user не существует")
        
        cursor.close()
        conn.close()
        print("\n✅ Удаление таблицы user завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    remove_user_table()
