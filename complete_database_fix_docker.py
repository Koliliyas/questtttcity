#!/usr/bin/env python3
"""
Полное исправление серверной базы данных на основе правильной структуры из миграций
(Версия для Docker контейнера)
"""
import psycopg2
import uuid
import bcrypt
from datetime import datetime

# Параметры подключения к серверной базе данных (внутри Docker контейнера)
SERVER_DB_CONFIG = {
    'host': 'localhost',  # Внутри контейнера база данных доступна через localhost
    'port': 5432,
    'database': 'questcity',
    'user': 'postgres',
    'password': 'postgres'
}

def complete_database_fix():
    """Полное исправление серверной базы данных"""
    print("🔧 Полное исправление серверной базы данных")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Шаг 1: Создаем правильную таблицу profile
        print("\n📋 Шаг 1: Создание правильной таблицы profile")
        cursor.execute("""
            DROP TABLE IF EXISTS profile CASCADE;
        """)
        print("  ✅ Удалена старая таблица profile")

        cursor.execute("""
            CREATE TABLE profile (
                id SERIAL PRIMARY KEY,
                avatar_url VARCHAR(1024),
                instagram_username VARCHAR(1024) NOT NULL DEFAULT '',
                credits INTEGER NOT NULL DEFAULT 0
            );
        """)
        print("  ✅ Создана новая таблица profile с правильной структурой")

        # Шаг 2: Создаем правильную таблицу user
        print("\n📋 Шаг 2: Создание правильной таблицы user")
        cursor.execute("""
            DROP TABLE IF EXISTS "user" CASCADE;
        """)
        print("  ✅ Удалена старая таблица user")

        cursor.execute("""
            CREATE TABLE "user" (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                username VARCHAR(15) NOT NULL UNIQUE,
                first_name VARCHAR(128) NOT NULL,
                last_name VARCHAR(128) NOT NULL,
                full_name VARCHAR(257) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
                password VARCHAR(1024) NOT NULL,
                email VARCHAR(30) NOT NULL UNIQUE,
                profile_id INTEGER NOT NULL UNIQUE REFERENCES profile(id) ON DELETE CASCADE,
                role INTEGER NOT NULL DEFAULT 0,
                is_active BOOLEAN NOT NULL DEFAULT true,
                is_verified BOOLEAN NOT NULL DEFAULT false,
                can_edit_quests BOOLEAN NOT NULL DEFAULT false,
                can_lock_users BOOLEAN NOT NULL DEFAULT false,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        print("  ✅ Создана новая таблица user с правильной структурой")

        # Создаем индексы для user
        cursor.execute("""
            CREATE INDEX ix_user_email ON "user" (email);
        """)
        cursor.execute("""
            CREATE INDEX ix_user_username ON "user" (username);
        """)
        print("  ✅ Созданы индексы для таблицы user")

        # Шаг 3: Создаем таблицу point_type
        print("\n📋 Шаг 3: Создание таблицы point_type")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS point_type (
                id SERIAL PRIMARY KEY,
                name VARCHAR NOT NULL,
                description TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        print("  ✅ Создана таблица point_type")

        # Шаг 4: Исправляем таблицу point
        print("\n📋 Шаг 4: Исправление таблицы point")
        cursor.execute("""
            DROP TABLE IF EXISTS point CASCADE;
        """)
        print("  ✅ Удалена старая таблица point")

        cursor.execute("""
            CREATE TABLE point (
                id SERIAL PRIMARY KEY,
                name_of_location VARCHAR(32) NOT NULL,
                "order" INTEGER NOT NULL,
                description TEXT NOT NULL,
                type_id INTEGER NOT NULL REFERENCES point_type(id),
                tool_id INTEGER REFERENCES tool(id),
                is_divide BOOLEAN DEFAULT false,
                quest_id INTEGER NOT NULL REFERENCES quest(id) ON DELETE CASCADE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        print("  ✅ Создана новая таблица point с правильной структурой")

        # Создаем индексы для point
        cursor.execute("""
            CREATE INDEX ix_point_quest_id ON point (quest_id);
        """)
        cursor.execute("""
            CREATE INDEX ix_point_type_id ON point (type_id);
        """)
        print("  ✅ Созданы индексы для таблицы point")

        # Шаг 5: Создаем таблицу place_settings
        print("\n📋 Шаг 5: Создание таблицы place_settings")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS place_settings (
                id SERIAL PRIMARY KEY,
                longitude DOUBLE PRECISION NOT NULL,
                latitude DOUBLE PRECISION NOT NULL,
                detections_radius DOUBLE PRECISION NOT NULL,
                height DOUBLE PRECISION NOT NULL,
                random_occurrence DOUBLE PRECISION,
                interaction_inaccuracy DOUBLE PRECISION NOT NULL,
                part INTEGER,
                point_id INTEGER NOT NULL REFERENCES point(id) ON DELETE CASCADE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        print("  ✅ Создана таблица place_settings")

        # Шаг 6: Заполняем point_type данными из activity
        print("\n📋 Шаг 6: Заполнение point_type данными из activity")
        cursor.execute("""
            INSERT INTO point_type (id, name, description)
            SELECT id, name, name as description FROM activity
            ON CONFLICT (id) DO NOTHING;
        """)
        print("  ✅ Заполнена таблица point_type")

        # Шаг 7: Создаем админа
        print("\n📋 Шаг 7: Создание админа")
        
        # Создаем профиль для админа
        cursor.execute("""
            INSERT INTO profile (id, instagram_username, credits)
            VALUES (1, 'admin', 1000)
            ON CONFLICT (id) DO NOTHING;
        """)
        
        # Хешируем пароль
        password = "admin123"
        hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        
        # Создаем пользователя админа
        cursor.execute("""
            INSERT INTO "user" (id, username, first_name, last_name, password, email, profile_id, role, is_active, is_verified, can_edit_quests, can_lock_users)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (email) DO NOTHING;
        """, (
            str(uuid.uuid4()),
            'admin',
            'Admin',
            'User',
            hashed_password,
            'admin@questcity.com',
            1,
            1,  # role = 1 для админа
            True,
            True,
            True,
            True
        ))
        print("  ✅ Создан админ: admin@questcity.com / admin123")

        # Шаг 8: Обновляем справочные данные
        print("\n📋 Шаг 8: Обновление справочных данных")
        
        # Обновляем category
        cursor.execute("""
            UPDATE category SET name = CASE 
                WHEN id = 1 THEN 'Приключения'
                WHEN id = 2 THEN 'Детектив'
                WHEN id = 3 THEN 'История'
                WHEN id = 4 THEN 'Наука'
                ELSE name
            END WHERE id IN (1, 2, 3, 4);
        """)
        
        # Обновляем vehicle
        cursor.execute("""
            UPDATE vehicle SET name = CASE 
                WHEN id = 1 THEN 'Пешком'
                WHEN id = 2 THEN 'Велосипед'
                WHEN id = 3 THEN 'Автомобиль'
                WHEN id = 4 THEN 'Общественный транспорт'
                ELSE name
            END WHERE id IN (1, 2, 3, 4);
        """)
        
        # Обновляем place
        cursor.execute("""
            UPDATE place SET name = CASE 
                WHEN id = 1 THEN 'Центр города'
                WHEN id = 2 THEN 'Парк'
                WHEN id = 3 THEN 'Музей'
                WHEN id = 4 THEN 'Торговый центр'
                ELSE name
            END WHERE id IN (1, 2, 3, 4);
        """)
        
        # Обновляем activity
        cursor.execute("""
            UPDATE activity SET name = CASE 
                WHEN id = 1 THEN 'Фото'
                WHEN id = 2 THEN 'Видео'
                WHEN id = 3 THEN 'Текст'
                WHEN id = 4 THEN 'Аудио'
                ELSE name
            END WHERE id IN (1, 2, 3, 4);
        """)
        
        # Обновляем tool
        cursor.execute("""
            UPDATE tool SET name = CASE 
                WHEN id = 1 THEN 'Камера'
                WHEN id = 2 THEN 'Компас'
                WHEN id = 3 THEN 'Карта'
                WHEN id = 4 THEN 'Фонарик'
                ELSE name
            END WHERE id IN (1, 2, 3, 4);
        """)
        print("  ✅ Обновлены справочные данные")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Полное исправление базы данных завершено!")
        print("\n📋 Что было сделано:")
        print("  1. ✅ Пересоздана таблица profile с правильной структурой")
        print("  2. ✅ Пересоздана таблица user с правильной структурой")
        print("  3. ✅ Создана таблица point_type")
        print("  4. ✅ Пересоздана таблица point с правильной структурой")
        print("  5. ✅ Создана таблица place_settings")
        print("  6. ✅ Заполнена таблица point_type данными")
        print("  7. ✅ Создан админ: admin@questcity.com / admin123")
        print("  8. ✅ Обновлены справочные данные")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = complete_database_fix()
    
    if not success:
        print("\n❌ Не удалось исправить базу данных")

if __name__ == "__main__":
    main()
