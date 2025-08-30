#!/usr/bin/env python3
"""
Проверка таблиц, связанных с квестами
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

def check_quest_related_tables():
    """Проверка таблиц, связанных с квестами"""
    print("🔍 ПРОВЕРКА ТАБЛИЦ, СВЯЗАННЫХ С КВЕСТАМИ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем таблицу quest
        print("\n📋 Структура таблицы quest:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'quest'
            ORDER BY ordinal_position
        """)
        quest_columns = cursor.fetchall()
        
        for col in quest_columns:
            print(f"  - {col[0]}: {col[1]} (nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем таблицу point
        print("\n📋 Структура таблицы point:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'point'
            ORDER BY ordinal_position
        """)
        point_columns = cursor.fetchall()
        
        for col in point_columns:
            print(f"  - {col[0]}: {col[1]} (nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем таблицу tool
        print("\n📋 Структура таблицы tool:")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'tool'
            ORDER BY ordinal_position
        """)
        tool_columns = cursor.fetchall()
        
        for col in tool_columns:
            print(f"  - {col[0]}: {col[1]} (nullable: {col[2]}, default: {col[3]})")
        
        # Проверяем данные в таблице quest
        print("\n📋 Данные в таблице quest:")
        cursor.execute('SELECT id, title, description FROM quest LIMIT 5')
        quests = cursor.fetchall()
        
        print(f"  📊 Количество записей: {len(quests)}")
        for quest in quests:
            print(f"    - ID: {quest[0]} | Title: {quest[1][:50] if quest[1] else 'None'}...")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_quest_related_tables()
