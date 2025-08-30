#!/usr/bin/env python3
"""
Исправление таблицы tool
"""
import psycopg2

# Параметры подключения к внешней базе данных PostgreSQL
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def fix_tool_table():
    """Исправление таблицы tool"""
    print("🔧 Исправление таблицы tool")
    print("=" * 80)

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Сохраняем данные из старой таблицы tool
        print("\n📋 Сохранение данных из старой таблицы tool")
        cursor.execute("SELECT id, name, image FROM tool")
        tool_data = cursor.fetchall()
        print(f"  📊 Сохранено {len(tool_data)} записей")

        # Удаляем старую таблицу tool
        print("\n📋 Удаление старой таблицы tool")
        cursor.execute("DROP TABLE IF EXISTS tool CASCADE")
        print("  ✅ Старая таблица tool удалена")

        # Создаем новую таблицу tool с правильной структурой
        print("\n📋 Создание новой таблицы tool")
        cursor.execute("""
            CREATE TABLE tool (
                id SERIAL PRIMARY KEY,
                name VARCHAR(32) NOT NULL,
                image VARCHAR(1024) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        print("  ✅ Новая таблица tool создана")

        # Восстанавливаем данные
        print("\n📋 Восстановление данных в таблицу tool")
        for tool_id, name, image in tool_data:
            cursor.execute("""
                INSERT INTO tool (id, name, image)
                VALUES (%s, %s, %s)
                ON CONFLICT (id) DO NOTHING;
            """, (tool_id, name, image))
        print("  ✅ Данные восстановлены")

        # Проверяем результат
        cursor.execute("SELECT COUNT(*) FROM tool")
        count = cursor.fetchone()[0]
        print(f"  📊 Количество записей в новой таблице tool: {count}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Исправление таблицы tool завершено")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = fix_tool_table()
    
    if not success:
        print("\n❌ Не удалось исправить таблицу tool")

if __name__ == "__main__":
    main()
