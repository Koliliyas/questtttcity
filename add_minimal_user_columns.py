#!/usr/bin/env python3
"""
Добавление минимально необходимых колонок в таблицу user
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

def add_minimal_user_columns():
    """Добавление минимально необходимых колонок"""
    print("🔧 ДОБАВЛЕНИЕ МИНИМАЛЬНО НЕОБХОДИМЫХ КОЛОНОК В USER")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Добавляем только необходимые колонки
        print("\n🔧 Добавление колонки profile_id...")
        cursor.execute('ALTER TABLE "user" ADD COLUMN IF NOT EXISTS profile_id INTEGER')
        print("  ✅ Колонка profile_id добавлена")
        
        # Обновляем profile_id для админа
        print("\n🔧 Обновление profile_id для админа...")
        cursor.execute('UPDATE "user" SET profile_id = 1 WHERE email = %s', ('admin@questcity.com',))
        print("  ✅ Profile_id обновлен для админа")
        
        cursor.close()
        conn.close()
        print("\n✅ Добавление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    add_minimal_user_columns()
