#!/usr/bin/env python3
"""
Создание недостающих таблиц quest и point
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

def create_missing_tables():
    """Создает недостающие таблицы"""
    print("🔧 СОЗДАНИЕ НЕДОСТАЮЩИХ ТАБЛИЦ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # 1. Создаем таблицу quest
        print("\n🔧 Создание таблицы quest...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS quest (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                description TEXT NOT NULL,
                category_id INTEGER NOT NULL REFERENCES category(id),
                vehicle_id INTEGER NOT NULL REFERENCES vehicle(id),
                place_id INTEGER NOT NULL REFERENCES place(id),
                group_name VARCHAR(50) NOT NULL,
                level VARCHAR(50) NOT NULL,
                mileage INTEGER NOT NULL,
                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
                updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
                owner_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE
            )
        """)
        print("  ✅ Таблица quest создана")
        
        # 2. Создаем таблицу point
        print("\n🔧 Создание таблицы point...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS point (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                description TEXT NOT NULL,
                coordinates JSONB NOT NULL,
                quest_id INTEGER NOT NULL REFERENCES quest(id) ON DELETE CASCADE,
                order_index INTEGER NOT NULL,
                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
                updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc', now()) NOT NULL
            )
        """)
        print("  ✅ Таблица point создана")
        
        cursor.close()
        conn.close()
        print("\n✅ Создание завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    create_missing_tables()
