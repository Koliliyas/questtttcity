#!/usr/bin/env python3
"""
Исправление последовательности profile
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

def fix_profile_sequence():
    """Исправление последовательности profile"""
    print("🔧 ИСПРАВЛЕНИЕ ПОСЛЕДОВАТЕЛЬНОСТИ PROFILE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем текущие значения последовательностей
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
        
        # Проверяем максимальный ID в таблице profile
        print("\n📋 Максимальный ID в таблице profile:")
        cursor.execute('SELECT MAX(id) FROM profile')
        max_id = cursor.fetchone()
        print(f"  - Максимальный ID: {max_id[0] if max_id[0] else 0}")
        
        # Исправляем последовательность profile_id_seq1
        print("\n🔧 Исправление последовательности profile_id_seq1...")
        try:
            cursor.execute("SELECT setval('profile_id_seq1', %s, true)", (max_id[0] if max_id[0] else 1,))
            print("  ✅ Последовательность исправлена")
        except Exception as e:
            print(f"  ❌ Ошибка исправления последовательности: {e}")
        
        # Проверяем результат
        print("\n📋 Проверка результата:")
        try:
            cursor.execute("SELECT last_value FROM profile_id_seq1")
            new_last_value = cursor.fetchone()
            print(f"  - Новое значение profile_id_seq1: {new_last_value[0] if new_last_value else 'N/A'}")
        except Exception as e:
            print(f"  - Ошибка проверки: {e}")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_profile_sequence()
