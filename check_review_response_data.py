#!/usr/bin/env python3
"""
Проверка данных в таблице review_response
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

def check_review_response_data():
    """Проверка данных в таблице review_response"""
    print("🔍 ПРОВЕРКА ДАННЫХ В ТАБЛИЦЕ REVIEW_RESPONSE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем структуру таблицы review_response
        print("\n📋 Структура таблицы review_response:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'review_response'
            ORDER BY ordinal_position
        """)
        columns = cursor.fetchall()
        
        for col in columns:
            print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")
        
        # Проверяем данные в таблице review_response
        print("\n📋 Данные в таблице review_response:")
        cursor.execute('SELECT id, user_id, review_id, text FROM review_response')
        responses = cursor.fetchall()
        
        print(f"  📊 Количество записей: {len(responses)}")
        for response in responses:
            print(f"    - ID: {response[0]} | User ID: {response[1]} | Review ID: {response[2]} | Text: {response[3][:50] if response[3] else 'None'}...")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_review_response_data()
