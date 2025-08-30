#!/usr/bin/env python3
"""
Добавление тестовых данных в таблицу quest
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

def add_test_quest_data():
    """Добавление тестовых данных в таблицу quest"""
    print("🔧 ДОБАВЛЕНИЕ ТЕСТОВЫХ ДАННЫХ В ТАБЛИЦУ QUEST")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Добавление тестового квеста...")
        
        # Добавляем тестовый квест
        cursor.execute("""
            INSERT INTO quest (
                name, description, image, mentor_preference, auto_accrual, 
                cost, reward, category_id, vehicle_id, is_subscription, 
                pay_extra, timeframe, level, milage, place_id
            ) VALUES (
                'Test Quest', 'This is a test quest for testing purposes', 
                'test_image.jpg', 'any', false, 100, 200, 1, 1, false, 
                0, '1 hour', 'beginner', '5 km', 1
            )
        """)
        print("  ✅ Тестовый квест добавлен")
        
        # Проверяем результат
        cursor.execute('SELECT id, name, description FROM quest')
        quests = cursor.fetchall()
        
        print(f"  📊 Количество квестов: {len(quests)}")
        for quest in quests:
            print(f"    - ID: {quest[0]} | Name: {quest[1]} | Description: {quest[2][:50]}...")
        
        cursor.close()
        conn.close()
        print("\n✅ Добавление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    add_test_quest_data()
