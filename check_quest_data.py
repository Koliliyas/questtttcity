#!/usr/bin/env python3
"""
Проверка данных в таблице quest
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

def check_quest_data():
    """Проверка данных в таблице quest"""
    print("🔍 ПРОВЕРКА ДАННЫХ В ТАБЛИЦЕ QUEST")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем данные в таблице quest
        print("\n📋 Данные в таблице quest:")
        cursor.execute('SELECT id, name, description FROM quest LIMIT 5')
        quests = cursor.fetchall()
        
        print(f"  📊 Количество записей: {len(quests)}")
        for quest in quests:
            print(f"    - ID: {quest[0]} | Name: {quest[1][:50] if quest[1] else 'None'}...")
        
        # Проверяем данные в таблице tool
        print("\n📋 Данные в таблице tool:")
        cursor.execute('SELECT id, name, image FROM tool LIMIT 5')
        tools = cursor.fetchall()
        
        print(f"  📊 Количество записей: {len(tools)}")
        for tool in tools:
            print(f"    - ID: {tool[0]} | Name: {tool[1][:50] if tool[1] else 'None'}...")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_quest_data()
