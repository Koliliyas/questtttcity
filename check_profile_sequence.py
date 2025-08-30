#!/usr/bin/env python3
"""
Проверка последовательности таблицы profile
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

def check_profile_sequence():
    """Проверка последовательности таблицы profile"""
    print("🔍 ПРОВЕРКА ПОСЛЕДОВАТЕЛЬНОСТИ ТАБЛИЦЫ PROFILE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем, какая последовательность используется в таблице profile
        print("\n📋 Проверка последовательности для таблицы profile:")
        cursor.execute("""
            SELECT column_name, column_default
            FROM information_schema.columns 
            WHERE table_name = 'profile' AND column_name = 'id'
        """)
        column_info = cursor.fetchone()
        
        if column_info:
            print(f"📊 Колонка: {column_info[0]}")
            print(f"📊 Default: {column_info[1]}")
        
        # Проверяем текущие значения обеих последовательностей
        print("\n📋 Текущие значения последовательностей:")
        try:
            cursor.execute("SELECT last_value FROM profile_id_seq")
            last_value1 = cursor.fetchone()
            print(f"  - profile_id_seq: {last_value1[0] if last_value1 else 'N/A'}")
        except Exception as e:
            print(f"  - profile_id_seq: ошибка - {e}")
        
        try:
            cursor.execute("SELECT last_value FROM profile_id_seq1")
            last_value2 = cursor.fetchone()
            print(f"  - profile_id_seq1: {last_value2[0] if last_value2 else 'N/A'}")
        except Exception as e:
            print(f"  - profile_id_seq1: ошибка - {e}")
        
        # Проверяем данные в таблице profile
        print("\n📋 Данные в таблице profile:")
        cursor.execute('SELECT id, instagram_username, credits FROM profile ORDER BY id')
        profiles = cursor.fetchall()
        print(f"  📊 Количество записей: {len(profiles)}")
        for profile in profiles:
            print(f"    - ID: {profile[0]} | Instagram: {profile[1]} | Credits: {profile[2]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_profile_sequence()
