#!/usr/bin/env python3
"""
Проверка структуры таблицы tool
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

def check_tool_table():
    """Проверка структуры таблицы tool"""
    print("🔍 Проверка структуры таблицы tool")
    print("=" * 80)

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Проверяем существование таблицы tool
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'tool'
            );
        """)
        exists = cursor.fetchone()[0]
        print(f"📋 Таблица tool существует: {exists}")

        if exists:
            # Проверяем структуру таблицы tool
            cursor.execute("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_schema = 'public' AND table_name = 'tool'
                ORDER BY ordinal_position
            """)
            columns = cursor.fetchall()
            print(f"📋 Структура таблицы tool:")
            for col in columns:
                default = col[3] if col[3] else 'NULL'
                print(f"  - {col[0]}: {col[1]} (nullable: {col[2]}, default: {default})")

            # Проверяем первичный ключ
            cursor.execute("""
                SELECT constraint_name, constraint_type
                FROM information_schema.table_constraints 
                WHERE table_schema = 'public' 
                AND table_name = 'tool' 
                AND constraint_type = 'PRIMARY KEY'
            """)
            pk = cursor.fetchall()
            print(f"📋 Первичный ключ: {pk}")

            # Проверяем данные
            cursor.execute("SELECT COUNT(*) FROM tool")
            count = cursor.fetchone()[0]
            print(f"📊 Количество записей в tool: {count}")

            if count > 0:
                cursor.execute("SELECT * FROM tool LIMIT 3")
                rows = cursor.fetchall()
                print(f"📄 Примеры данных: {rows}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_tool_table()
    
    if not success:
        print("\n❌ Не удалось проверить таблицу tool")

if __name__ == "__main__":
    main()
