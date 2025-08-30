#!/usr/bin/env python3
"""
Добавление недостающих колонок в таблицу quest
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

def add_missing_columns():
    """Добавляет недостающие колонки в таблицу quest"""
    print("🔧 ДОБАВЛЕНИЕ НЕДОСТАЮЩИХ КОЛОНОК В QUEST")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Добавляем колонку image
        print("\n🔧 Добавление колонки image...")
        cursor.execute("ALTER TABLE quest ADD COLUMN IF NOT EXISTS image VARCHAR(255)")
        print("  ✅ Колонка image добавлена")
        
        # Добавляем колонку difficulty
        print("\n🔧 Добавление колонки difficulty...")
        cursor.execute("ALTER TABLE quest ADD COLUMN IF NOT EXISTS difficulty VARCHAR(50)")
        print("  ✅ Колонка difficulty добавлена")
        
        # Добавляем колонку duration
        print("\n🔧 Добавление колонки duration...")
        cursor.execute("ALTER TABLE quest ADD COLUMN IF NOT EXISTS duration INTEGER")
        print("  ✅ Колонка duration добавлена")
        
        # Добавляем колонку max_participants
        print("\n🔧 Добавление колонки max_participants...")
        cursor.execute("ALTER TABLE quest ADD COLUMN IF NOT EXISTS max_participants INTEGER")
        print("  ✅ Колонка max_participants добавлена")
        
        # Добавляем колонку price
        print("\n🔧 Добавление колонки price...")
        cursor.execute("ALTER TABLE quest ADD COLUMN IF NOT EXISTS price DECIMAL(10,2)")
        print("  ✅ Колонка price добавлена")
        
        # Добавляем колонку location
        print("\n🔧 Добавление колонки location...")
        cursor.execute("ALTER TABLE quest ADD COLUMN IF NOT EXISTS location VARCHAR(255)")
        print("  ✅ Колонка location добавлена")
        
        # Добавляем колонку coordinates
        print("\n🔧 Добавление колонки coordinates...")
        cursor.execute("ALTER TABLE quest ADD COLUMN IF NOT EXISTS coordinates JSONB")
        print("  ✅ Колонка coordinates добавлена")
        
        cursor.close()
        conn.close()
        print("\n✅ Добавление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    add_missing_columns()
