#!/usr/bin/env python3
"""
Исправление таблицы quest
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

def fix_quest_table():
    """Исправляет таблицу quest"""
    print("🔧 ИСПРАВЛЕНИЕ ТАБЛИЦЫ QUEST")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Переименовываем колонку title в name
        print("\n🔧 Переименование колонки title в name...")
        cursor.execute("ALTER TABLE quest RENAME COLUMN title TO name")
        print("  ✅ Колонка title переименована в name")
        
        # Переименовываем колонку group_name в group
        print("\n🔧 Переименование колонки group_name в group...")
        cursor.execute("ALTER TABLE quest RENAME COLUMN group_name TO \"group\"")
        print("  ✅ Колонка group_name переименована в group")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_quest_table()
