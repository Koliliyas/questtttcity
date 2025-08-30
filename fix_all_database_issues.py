#!/usr/bin/env python3
"""
Исправление всех проблем в серверной базе данных
"""
import psycopg2
import json
from typing import Dict, List, Any

# Конфигурация серверной базы данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def get_connection():
    """Создание подключения к серверной базе данных"""
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        return conn
    except Exception as e:
        print(f"❌ Ошибка подключения к БД: {e}")
        return None

def fix_all_issues():
    """Исправление всех проблем в базе данных"""
    print("🔧 ИСПРАВЛЕНИЕ ВСЕХ ПРОБЛЕМ В БАЗЕ ДАННЫХ")
    print("=" * 80)
    
    conn = get_connection()
    if not conn:
        return
    
    try:
        cursor = conn.cursor()
        
        # 1. Исправление таблицы point - добавление недостающих колонок
        print("\n🔧 Исправление таблицы point...")
        try:
            cursor.execute("""
                ALTER TABLE point 
                ADD COLUMN IF NOT EXISTS type_photo CHARACTER VARYING,
                ADD COLUMN IF NOT EXISTS type_code INTEGER,
                ADD COLUMN IF NOT EXISTS type_word CHARACTER VARYING,
                ADD COLUMN IF NOT EXISTS file CHARACTER VARYING
            """)
            print("  ✅ Колонки добавлены в таблицу point")
        except Exception as e:
            print(f"  ❌ Ошибка добавления колонок в point: {e}")
        
        # 2. Исправление таблицы review - переименование колонок
        print("\n🔧 Исправление таблицы review...")
        try:
            # Проверяем существование колонок
            cursor.execute("""
                SELECT column_name FROM information_schema.columns 
                WHERE table_name = 'review' AND column_name IN ('text', 'user_id', 'review', 'owner_id')
            """)
            existing_columns = [row[0] for row in cursor.fetchall()]
            
            if 'text' in existing_columns and 'review' not in existing_columns:
                cursor.execute("ALTER TABLE review RENAME COLUMN text TO review")
                print("  ✅ Колонка text переименована в review")
            
            if 'user_id' in existing_columns and 'owner_id' not in existing_columns:
                cursor.execute("ALTER TABLE review RENAME COLUMN user_id TO owner_id")
                print("  ✅ Колонка user_id переименована в owner_id")
            
            # Изменяем тип колонки review на text
            cursor.execute("ALTER TABLE review ALTER COLUMN review TYPE TEXT")
            print("  ✅ Тип колонки review изменен на TEXT")
            
            # Изменяем тип колонки owner_id на INTEGER
            cursor.execute("ALTER TABLE review ALTER COLUMN owner_id TYPE INTEGER")
            print("  ✅ Тип колонки owner_id изменен на INTEGER")
            
        except Exception as e:
            print(f"  ❌ Ошибка исправления review: {e}")
        
        # 3. Исправление таблицы quest - изменение типов данных
        print("\n🔧 Исправление таблицы quest...")
        try:
            # Изменяем тип description на text
            cursor.execute("ALTER TABLE quest ALTER COLUMN description TYPE TEXT")
            print("  ✅ Тип колонки description изменен на TEXT")
            
            # Изменяем тип group на enum (создаем enum если не существует)
            cursor.execute("""
                DO $$ 
                BEGIN
                    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'grouptype') THEN
                        CREATE TYPE grouptype AS ENUM ('ONE', 'TWO', 'THREE', 'FOUR');
                    END IF;
                END $$;
            """)
            
            cursor.execute("ALTER TABLE quest ALTER COLUMN group TYPE grouptype USING group::grouptype")
            print("  ✅ Тип колонки group изменен на enum")
            
            # Делаем group nullable
            cursor.execute("ALTER TABLE quest ALTER COLUMN group DROP NOT NULL")
            print("  ✅ Колонка group сделана nullable")
            
        except Exception as e:
            print(f"  ❌ Ошибка исправления quest: {e}")
        
        # 4. Исправление таблицы merch - изменение типа description
        print("\n🔧 Исправление таблицы merch...")
        try:
            cursor.execute("ALTER TABLE merch ALTER COLUMN description TYPE TEXT")
            print("  ✅ Тип колонки description изменен на TEXT")
        except Exception as e:
            print(f"  ❌ Ошибка исправления merch: {e}")
        
        # 5. Исправление временных зон в timestamp колонках
        print("\n🔧 Исправление временных зон...")
        tables_with_timestamps = ['category', 'quest', 'review']
        for table in tables_with_timestamps:
            try:
                cursor.execute(f"ALTER TABLE {table} ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE")
                cursor.execute(f"ALTER TABLE {table} ALTER COLUMN updated_at TYPE TIMESTAMP WITH TIME ZONE")
                print(f"  ✅ Временные зоны исправлены в таблице {table}")
            except Exception as e:
                print(f"  ⚠️ Не удалось исправить временные зоны в {table}: {e}")
        
        # 6. Удаление лишних колонок created_at и updated_at из point
        print("\n🔧 Удаление лишних колонок из point...")
        try:
            cursor.execute("ALTER TABLE point DROP COLUMN IF EXISTS created_at")
            cursor.execute("ALTER TABLE point DROP COLUMN IF EXISTS updated_at")
            print("  ✅ Лишние колонки удалены из point")
        except Exception as e:
            print(f"  ❌ Ошибка удаления колонок из point: {e}")
        
        # 7. Удаление лишних колонок created_at и updated_at из tool
        print("\n🔧 Удаление лишних колонок из tool...")
        try:
            cursor.execute("ALTER TABLE tool DROP COLUMN IF EXISTS created_at")
            cursor.execute("ALTER TABLE tool DROP COLUMN IF EXISTS updated_at")
            print("  ✅ Лишние колонки удалены из tool")
        except Exception as e:
            print(f"  ❌ Ошибка удаления колонок из tool: {e}")
        
        # 8. Удаление лишней колонки avatar_url из profile
        print("\n🔧 Удаление лишней колонки из profile...")
        try:
            cursor.execute("ALTER TABLE profile DROP COLUMN IF EXISTS avatar_url")
            print("  ✅ Лишняя колонка удалена из profile")
        except Exception as e:
            print(f"  ❌ Ошибка удаления колонки из profile: {e}")
        
        # 9. Синхронизация данных справочных таблиц
        print("\n🔧 Синхронизация справочных данных...")
        
        # Синхронизация activity
        try:
            cursor.execute("DELETE FROM activity")
            cursor.execute("""
                INSERT INTO activity (id, name, description, image) VALUES
                (1, 'Пешком', 'Пешие прогулки', 'walking.jpg'),
                (2, 'На велосипеде', 'Велосипедные прогулки', 'bicycle.jpg'),
                (3, 'На машине', 'Автомобильные поездки', 'car.jpg'),
                (4, 'На общественном транспорте', 'Поездки на общественном транспорте', 'public_transport.jpg'),
                (5, 'На самокате', 'Поездки на самокате', 'scooter.jpg'),
                (6, 'На роликах', 'Катание на роликах', 'rollerblades.jpg'),
                (7, 'На лыжах', 'Катание на лыжах', 'skiing.jpg'),
                (8, 'На коньках', 'Катание на коньках', 'skating.jpg'),
                (9, 'На лодке', 'Поездки на лодке', 'boat.jpg'),
                (10, 'На мотоцикле', 'Поездки на мотоцикле', 'motorcycle.jpg')
                ON CONFLICT (id) DO NOTHING
            """)
            print("  ✅ Данные activity синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации activity: {e}")
        
        # Синхронизация category
        try:
            cursor.execute("DELETE FROM category")
            cursor.execute("""
                INSERT INTO category (id, name, description, image) VALUES
                (1, 'Приключения', 'Захватывающие приключения', 'adventure.jpg'),
                (2, 'Детективы', 'Загадочные истории', 'detective.jpg'),
                (3, 'История', 'Исторические квесты', 'history.jpg'),
                (4, 'Наука', 'Научные эксперименты', 'science.jpg'),
                (5, 'Искусство', 'Творческие задания', 'art.jpg'),
                (6, 'Спорт', 'Спортивные соревнования', 'sport.jpg'),
                (7, 'Кулинария', 'Кулинарные мастер-классы', 'cooking.jpg'),
                (8, 'Технологии', 'Технологические квесты', 'technology.jpg')
                ON CONFLICT (id) DO NOTHING
            """)
            print("  ✅ Данные category синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации category: {e}")
        
        # Синхронизация place
        try:
            cursor.execute("DELETE FROM place")
            cursor.execute("""
                INSERT INTO place (id, name, description, image) VALUES
                (1, 'Парк', 'Городской парк', 'park.jpg'),
                (2, 'Музей', 'Исторический музей', 'museum.jpg'),
                (3, 'Библиотека', 'Публичная библиотека', 'library.jpg'),
                (4, 'Кафе', 'Уютное кафе', 'cafe.jpg'),
                (5, 'Театр', 'Драматический театр', 'theater.jpg'),
                (6, 'Стадион', 'Спортивный стадион', 'stadium.jpg'),
                (7, 'Торговый центр', 'Большой торговый центр', 'mall.jpg'),
                (8, 'Университет', 'Высшее учебное заведение', 'university.jpg'),
                (9, 'Больница', 'Медицинское учреждение', 'hospital.jpg'),
                (10, 'Полиция', 'Отделение полиции', 'police.jpg')
                ON CONFLICT (id) DO NOTHING
            """)
            print("  ✅ Данные place синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации place: {e}")
        
        # Синхронизация vehicle
        try:
            cursor.execute("DELETE FROM vehicle")
            cursor.execute("""
                INSERT INTO vehicle (id, name, description, image) VALUES
                (1, 'Пешком', 'Пешие прогулки', 'walking.jpg'),
                (2, 'Велосипед', 'Велосипедные прогулки', 'bicycle.jpg'),
                (3, 'Автомобиль', 'Автомобильные поездки', 'car.jpg'),
                (4, 'Общественный транспорт', 'Поездки на общественном транспорте', 'public_transport.jpg'),
                (5, 'Самокат', 'Поездки на самокате', 'scooter.jpg'),
                (6, 'Ролики', 'Катание на роликах', 'rollerblades.jpg')
                ON CONFLICT (id) DO NOTHING
            """)
            print("  ✅ Данные vehicle синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации vehicle: {e}")
        
        # Синхронизация tool
        try:
            cursor.execute("DELETE FROM tool")
            cursor.execute("""
                INSERT INTO tool (id, name, description, image) VALUES
                (1, 'Компас', 'Навигационный компас', 'compass.jpg'),
                (2, 'Карта', 'Детальная карта местности', 'map.jpg'),
                (3, 'Фонарик', 'Портативный фонарик', 'flashlight.jpg'),
                (4, 'Бинокль', 'Оптический бинокль', 'binoculars.jpg'),
                (5, 'Камера', 'Фотоаппарат', 'camera.jpg'),
                (6, 'Телефон', 'Мобильный телефон', 'phone.jpg'),
                (7, 'Часы', 'Наручные часы', 'watch.jpg'),
                (8, 'Рюкзак', 'Походный рюкзак', 'backpack.jpg'),
                (9, 'Вода', 'Бутылка воды', 'water.jpg'),
                (10, 'Еда', 'Продукты питания', 'food.jpg')
                ON CONFLICT (id) DO NOTHING
            """)
            print("  ✅ Данные tool синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации tool: {e}")
        
        # 10. Очистка таблицы quest (удаляем все квесты)
        print("\n🔧 Очистка таблицы quest...")
        try:
            cursor.execute("DELETE FROM quest")
            print("  ✅ Таблица quest очищена")
        except Exception as e:
            print(f"  ❌ Ошибка очистки quest: {e}")
        
        cursor.close()
        print("\n✅ Все исправления выполнены!")
        
    except Exception as e:
        print(f"❌ Общая ошибка: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    fix_all_issues()
