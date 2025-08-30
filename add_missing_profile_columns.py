#!/usr/bin/env python3
"""
Добавление недостающих колонок в таблицу profile
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

def add_missing_profile_columns():
    """Добавление недостающих колонок в таблицу profile"""
    print("🔧 ДОБАВЛЕНИЕ НЕДОСТАЮЩИХ КОЛОНОК В ТАБЛИЦУ PROFILE")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Добавляем недостающие колонки
        print("\n🔧 Добавление недостающих колонок...")
        
        columns_to_add = [
            ('avatar_url', 'VARCHAR(1024)'),
            ('bio', 'TEXT'),
            ('phone', 'VARCHAR(20)'),
            ('birth_date', 'DATE'),
            ('gender', 'VARCHAR(10)'),
            ('location', 'VARCHAR(255)'),
            ('website', 'VARCHAR(255)'),
            ('social_links', 'JSON'),
            ('preferences', 'JSON'),
            ('settings', 'JSON')
        ]
        
        for col_name, col_type in columns_to_add:
            cursor.execute(f'ALTER TABLE profile ADD COLUMN IF NOT EXISTS {col_name} {col_type}')
            print(f"  ✅ Колонка {col_name} добавлена")
        
        cursor.close()
        conn.close()
        print("\n✅ Добавление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    add_missing_profile_columns()
