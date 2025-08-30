#!/usr/bin/env python3
"""
Добавление недостающих колонок в таблицу user
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

def add_missing_user_columns():
    """Добавление недостающих колонок в таблицу user"""
    print("🔧 ДОБАВЛЕНИЕ НЕДОСТАЮЩИХ КОЛОНОК В ТАБЛИЦУ USER")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Добавляем недостающие колонки
        print("\n🔧 Добавление недостающих колонок...")
        
        columns_to_add = [
            ('first_name', 'VARCHAR(255)'),
            ('last_name', 'VARCHAR(255)'),
            ('full_name', 'VARCHAR(255)'),
            ('role', 'VARCHAR(50)'),
            ('is_verified', 'BOOLEAN DEFAULT false'),
            ('can_edit_quests', 'BOOLEAN DEFAULT false'),
            ('can_lock_users', 'BOOLEAN DEFAULT false')
        ]
        
        for col_name, col_type in columns_to_add:
            cursor.execute(f'ALTER TABLE "user" ADD COLUMN IF NOT EXISTS {col_name} {col_type}')
            print(f"  ✅ Колонка {col_name} добавлена")
        
        # Обновляем данные админа
        print("\n🔧 Обновление данных админа...")
        cursor.execute("""
            UPDATE "user" SET 
                first_name = 'Admin',
                last_name = 'User',
                full_name = 'Admin User',
                role = 'admin',
                is_verified = true,
                can_edit_quests = true,
                can_lock_users = true
            WHERE email = %s
        """, ('admin@questcity.com',))
        print("  ✅ Данные админа обновлены")
        
        cursor.close()
        conn.close()
        print("\n✅ Добавление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    add_missing_user_columns()
