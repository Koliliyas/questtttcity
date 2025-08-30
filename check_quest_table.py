#!/usr/bin/env python3
"""
Проверка структуры таблицы quest
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

def check_quest_table():
    """Проверяет структуру таблицы quest"""
    print("🔧 ПРОВЕРКА СТРУКТУРЫ ТАБЛИЦЫ QUEST")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем структуру таблицы quest
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'quest'
            ORDER BY ordinal_position
        """)
        
        columns = cursor.fetchall()
        print(f"\n📋 Структура таблицы quest:")
        for col in columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем данные
        cursor.execute("SELECT COUNT(*) FROM quest")
        count = cursor.fetchone()[0]
        print(f"\n📊 Количество записей в таблице quest: {count}")
        
        if count > 0:
            cursor.execute("SELECT * FROM quest LIMIT 3")
            quests = cursor.fetchall()
            print(f"\n📊 Примеры записей:")
            for quest in quests:
                print(f"  - {quest}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_quest_table()
