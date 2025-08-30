#!/usr/bin/env python3
"""
Финальное исправление всех проблем в серверной базе данных
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

def get_table_structure(conn, table_name: str) -> List[str]:
    """Получение структуры таблицы"""
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT column_name FROM information_schema.columns 
            WHERE table_name = %s 
            ORDER BY ordinal_position
        """, (table_name,))
        columns = [row[0] for row in cursor.fetchall()]
        cursor.close()
        return columns
    except Exception as e:
        print(f"❌ Ошибка получения структуры таблицы {table_name}: {e}")
        return []

def fix_all_issues():
    """Исправление всех проблем в базе данных"""
    print("🔧 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ВСЕХ ПРОБЛЕМ В БАЗЕ ДАННЫХ")
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
            
            # Для owner_id сначала создаем новую колонку, копируем данные, удаляем старую
            cursor.execute("ALTER TABLE review ADD COLUMN IF NOT EXISTS owner_id_new INTEGER")
            cursor.execute("UPDATE review SET owner_id_new = 1 WHERE owner_id_new IS NULL")
            cursor.execute("ALTER TABLE review DROP COLUMN IF EXISTS owner_id")
            cursor.execute("ALTER TABLE review RENAME COLUMN owner_id_new TO owner_id")
            print("  ✅ Колонка owner_id исправлена")
            
        except Exception as e:
            print(f"  ❌ Ошибка исправления review: {e}")
        
        # 3. Исправление таблицы quest - изменение типов данных
        print("\n🔧 Исправление таблицы quest...")
        try:
            # Изменяем тип description на text
            cursor.execute("ALTER TABLE quest ALTER COLUMN description TYPE TEXT")
            print("  ✅ Тип колонки description изменен на TEXT")
            
            # Создаем enum тип если не существует
            cursor.execute("""
                DO $$ 
                BEGIN
                    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'grouptype') THEN
                        CREATE TYPE grouptype AS ENUM ('ONE', 'TWO', 'THREE', 'FOUR');
                    END IF;
                END $$;
            """)
            
            # Изменяем тип колонки group на enum (используем кавычки для зарезервированного слова)
            cursor.execute('ALTER TABLE quest ALTER COLUMN "group" TYPE grouptype USING "group"::grouptype')
            print("  ✅ Тип колонки group изменен на enum")
            
            # Делаем group nullable
            cursor.execute('ALTER TABLE quest ALTER COLUMN "group" DROP NOT NULL')
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
        
        # 9. Синхронизация данных справочных таблиц (с учетом реальной структуры)
        print("\n🔧 Синхронизация справочных данных...")
        
        # Синхронизация activity (только id и name)
        try:
            cursor.execute("DELETE FROM activity")
            cursor.execute("""
                INSERT INTO activity (id, name) VALUES
                (1, 'Пешком'),
                (2, 'На велосипеде'),
                (3, 'На машине'),
                (4, 'На общественном транспорте'),
                (5, 'На самокате'),
                (6, 'На роликах'),
                (7, 'На лыжах'),
                (8, 'На коньках'),
                (9, 'На лодке'),
                (10, 'На мотоцикле')
            """)
            print("  ✅ Данные activity синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации activity: {e}")
        
        # Синхронизация category (с проверкой primary key)
        try:
            cursor.execute("DELETE FROM category")
            cursor.execute("""
                INSERT INTO category (id, name, image) VALUES
                (1, 'Приключения', 'adventure.jpg'),
                (2, 'Детективы', 'detective.jpg'),
                (3, 'История', 'history.jpg'),
                (4, 'Наука', 'science.jpg'),
                (5, 'Искусство', 'art.jpg'),
                (6, 'Спорт', 'sport.jpg'),
                (7, 'Кулинария', 'cooking.jpg'),
                (8, 'Технологии', 'technology.jpg')
            """)
            print("  ✅ Данные category синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации category: {e}")
        
        # Синхронизация place (только id и name)
        try:
            cursor.execute("DELETE FROM place")
            cursor.execute("""
                INSERT INTO place (id, name) VALUES
                (1, 'Парк'),
                (2, 'Музей'),
                (3, 'Библиотека'),
                (4, 'Кафе'),
                (5, 'Театр'),
                (6, 'Стадион'),
                (7, 'Торговый центр'),
                (8, 'Университет'),
                (9, 'Больница'),
                (10, 'Полиция')
            """)
            print("  ✅ Данные place синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации place: {e}")
        
        # Синхронизация vehicle (только id и name)
        try:
            cursor.execute("DELETE FROM vehicle")
            cursor.execute("""
                INSERT INTO vehicle (id, name) VALUES
                (1, 'Пешком'),
                (2, 'Велосипед'),
                (3, 'Автомобиль'),
                (4, 'Общественный транспорт'),
                (5, 'Самокат'),
                (6, 'Ролики')
            """)
            print("  ✅ Данные vehicle синхронизированы")
        except Exception as e:
            print(f"  ❌ Ошибка синхронизации vehicle: {e}")
        
        # Синхронизация tool (id, name, image)
        try:
            cursor.execute("DELETE FROM tool")
            cursor.execute("""
                INSERT INTO tool (id, name, image) VALUES
                (1, 'Компас', 'compass.jpg'),
                (2, 'Карта', 'map.jpg'),
                (3, 'Фонарик', 'flashlight.jpg'),
                (4, 'Бинокль', 'binoculars.jpg'),
                (5, 'Камера', 'camera.jpg'),
                (6, 'Телефон', 'phone.jpg'),
                (7, 'Часы', 'watch.jpg'),
                (8, 'Рюкзак', 'backpack.jpg'),
                (9, 'Вода', 'water.jpg'),
                (10, 'Еда', 'food.jpg')
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
