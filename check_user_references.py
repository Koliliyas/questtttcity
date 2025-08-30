#!/usr/bin/env python3
"""
Проверка всех колонок, которые могут ссылаться на user.id
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

def check_user_references():
    """Проверка всех колонок, которые могут ссылаться на user.id"""
    print("🔍 ПРОВЕРКА ВСЕХ КОЛОНОК, КОТОРЫЕ МОГУТ ССЫЛАТЬСЯ НА USER.ID")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем все колонки, которые могут ссылаться на user
        cursor.execute("""
            SELECT table_name, column_name, data_type
            FROM information_schema.columns 
            WHERE column_name LIKE '%user%' OR column_name LIKE '%owner%' OR column_name LIKE '%creator%'
            ORDER BY table_name, column_name
        """)
        user_columns = cursor.fetchall()
        
        print("📊 Все колонки, связанные с пользователями:")
        for col in user_columns:
            print(f"  - {col[0]}.{col[1]}: {col[2]}")
        
        # Проверяем все колонки с именем user_id
        cursor.execute("""
            SELECT table_name, column_name, data_type
            FROM information_schema.columns 
            WHERE column_name = 'user_id'
            ORDER BY table_name
        """)
        user_id_columns = cursor.fetchall()
        
        print("\n📊 Все колонки user_id:")
        for col in user_id_columns:
            print(f"  - {col[0]}.{col[1]}: {col[2]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_user_references()
