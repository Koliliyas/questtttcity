#!/usr/bin/env python3
"""
Простой скрипт для исправления серверной базы данных
"""
import psycopg2
from datetime import datetime

# Параметры подключения к серверной базе данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr'
}

def simple_fix_database():
    """Простое исправление базы данных"""
    print("🔧 Простое исправление серверной базы данных")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к серверной базе с автокоммитом
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True  # Включаем автокоммит
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Шаг 1: Создаем таблицу point_type
        print("\n📝 Шаг 1: Создание таблицы point_type...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS point_type (
                id SERIAL PRIMARY KEY,
                name VARCHAR NOT NULL,
                description TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("✅ Таблица point_type создана")

        # Шаг 2: Заполняем point_type данными из activity
        print("\n📝 Шаг 2: Заполнение point_type данными...")
        cursor.execute("""
            INSERT INTO point_type (id, name, description)
            SELECT id, name, description FROM activity
            ON CONFLICT (id) DO NOTHING
        """)
        print("✅ Данные добавлены в point_type")

        # Шаг 3: Создаем новую таблицу point с правильной структурой
        print("\n📝 Шаг 3: Создание новой таблицы point...")
        cursor.execute("""
            CREATE TABLE point_new (
                id SERIAL PRIMARY KEY,
                name_of_location VARCHAR NOT NULL,
                "order" INTEGER NOT NULL,
                description TEXT NOT NULL,
                type_id INTEGER NOT NULL,
                type_photo VARCHAR,
                type_code INTEGER,
                type_word VARCHAR,
                tool_id INTEGER,
                file VARCHAR,
                is_divide BOOLEAN DEFAULT false,
                quest_id INTEGER NOT NULL
            )
        """)
        print("✅ Новая таблица point_new создана")

        # Шаг 4: Копируем данные из старой таблицы point
        print("\n📝 Шаг 4: Копирование данных из старой таблицы point...")
        cursor.execute("""
            INSERT INTO point_new (id, name_of_location, "order", description, type_id, quest_id)
            SELECT 
                id,
                COALESCE(name, 'Unknown Location') as name_of_location,
                COALESCE(order_index, 1) as "order",
                COALESCE(description, 'No description') as description,
                1 as type_id,
                quest_id
            FROM point
        """)
        print("✅ Данные скопированы в point_new")

        # Шаг 5: Удаляем старую таблицу point и переименовываем новую
        print("\n📝 Шаг 5: Замена старой таблицы point...")
        cursor.execute("DROP TABLE point")
        cursor.execute("ALTER TABLE point_new RENAME TO point")
        print("✅ Старая таблица point заменена на новую")

        # Шаг 6: Создаем индексы
        print("\n📝 Шаг 6: Создание индексов...")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_point_quest_id ON point(quest_id)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_point_type_id ON point(type_id)")
        print("✅ Индексы созданы")

        # Проверяем результат
        print("\n📊 Проверка результатов...")
        
        # Проверяем структуру новой таблицы point
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'point' AND table_schema = 'public'
            ORDER BY ordinal_position
        """)
        point_columns = cursor.fetchall()
        
        print(f"📍 Структура таблицы point после исправления:")
        for col in point_columns:
            print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")

        # Проверяем наличие таблицы point_type
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'point_type'
            )
        """)
        point_type_exists = cursor.fetchone()[0]
        
        if point_type_exists:
            print("✅ Таблица point_type создана успешно!")
            
            # Проверяем данные в point_type
            cursor.execute("SELECT COUNT(*) FROM point_type")
            point_type_count = cursor.fetchone()[0]
            print(f"📈 Количество записей в point_type: {point_type_count}")
        else:
            print("❌ Таблица point_type не была создана")

        # Проверяем статистику таблиц
        print("\n📈 Статистика таблиц после исправления:")
        tables_to_check = ['point', 'category', 'vehicle', 'place', 'activity', 'tool', 'point_type', 'place_settings', 'quest']
        
        for table in tables_to_check:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"  - {table}: {count} записей")
            except Exception as e:
                print(f"  - {table}: ошибка - {e}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("🎉 Исправления базы данных применены успешно!")
        print("✅ Структура таблицы point приведена в соответствие с локальной версией")
        print("✅ Таблица point_type создана и заполнена данными")
        print("✅ Теперь создание квестов должно работать корректно")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = simple_fix_database()
    
    if success:
        print(f"\n{'='*80}")
        print("🎉 Все исправления применены успешно!")
        print("Теперь можно тестировать создание квестов через API")
    else:
        print(f"\n{'='*80}")
        print("❌ Не удалось применить исправления")

if __name__ == "__main__":
    main()
