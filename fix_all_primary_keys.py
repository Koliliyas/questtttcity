#!/usr/bin/env python3
"""
Исправление всех первичных ключей
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

def fix_all_primary_keys():
    """Исправляет все первичные ключи"""
    print("🔧 ИСПРАВЛЕНИЕ ВСЕХ ПЕРВИЧНЫХ КЛЮЧЕЙ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Список таблиц для исправления
        tables_to_fix = [
            'vehicle',
            'place',
            'activity',
            'tool'
        ]
        
        for table in tables_to_fix:
            print(f"\n🔧 Исправление таблицы {table}...")
            try:
                cursor.execute(f"ALTER TABLE {table} ADD CONSTRAINT {table}_pkey PRIMARY KEY (id)")
                print(f"  ✅ Первичный ключ добавлен к {table}")
            except Exception as e:
                if "already exists" in str(e):
                    print(f"  ⚠️ Первичный ключ уже существует для {table}")
                else:
                    print(f"  ❌ Ошибка для {table}: {e}")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_all_primary_keys()
