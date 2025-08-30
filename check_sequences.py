#!/usr/bin/env python3
"""
Проверка последовательностей (sequences) в базе данных
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

def check_sequences():
    """Проверка последовательностей"""
    print("🔍 ПРОВЕРКА ПОСЛЕДОВАТЕЛЬНОСТЕЙ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем все последовательности
        print("\n📋 Все последовательности:")
        cursor.execute("""
            SELECT sequence_name, data_type, start_value, minimum_value, maximum_value, increment
            FROM information_schema.sequences
            ORDER BY sequence_name
        """)
        sequences = cursor.fetchall()
        
        if sequences:
            print("📊 Найдены последовательности:")
            for seq in sequences:
                print(f"  - {seq[0]} ({seq[1]}, start: {seq[2]}, min: {seq[3]}, max: {seq[4]}, increment: {seq[5]})")
        else:
            print("  📊 Последовательностей не найдено")
        
        # Проверяем текущие значения последовательностей
        print("\n📋 Текущие значения последовательностей:")
        for seq in sequences:
            try:
                cursor.execute(f"SELECT last_value FROM {seq[0]}")
                last_value = cursor.fetchone()
                if last_value:
                    print(f"  - {seq[0]}: {last_value[0]}")
            except Exception as e:
                print(f"  - {seq[0]}: ошибка получения значения - {e}")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_sequences()
