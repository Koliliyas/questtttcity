#!/usr/bin/env python3
"""
Простой скрипт для проверки подключения к базе данных
"""

import psycopg2
import sys

def test_connection():
    """Тестирует подключение к базе данных PostgreSQL"""
    
    # Стандартные параметры подключения
    connection_params = [
        {
            'host': 'localhost',
            'port': 5432,
            'database': 'questcity',
            'user': 'postgres',
            'password': 'postgres'
        },
        {
            'host': 'localhost',
            'port': 5432,
            'database': 'postgres',
            'user': 'postgres',
            'password': 'postgres'
        },
        {
            'host': 'database',  # Docker container name
            'port': 5432,
            'database': 'questcity',
            'user': 'postgres',
            'password': 'postgres'
        }
    ]
    
    for params in connection_params:
        try:
            print(f"🔍 Пробуем подключиться к: {params['host']}:{params['port']}/{params['database']}")
            
            conn = psycopg2.connect(**params)
            cursor = conn.cursor()
            
            # Проверяем, есть ли таблица activity
            cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
            tables = cursor.fetchall()
            
            print(f"✅ Подключение успешно! Найдено таблиц: {len(tables)}")
            
            # Проверяем таблицу activity
            cursor.execute("SELECT COUNT(*) FROM activity")
            activity_count = cursor.fetchone()[0]
            print(f"📊 В таблице activity записей: {activity_count}")
            
            if activity_count > 0:
                cursor.execute("SELECT id, name FROM activity ORDER BY id LIMIT 5")
                activities = cursor.fetchall()
                print("📋 Первые 5 активностей:")
                for activity_id, name in activities:
                    print(f"  {activity_id}: {name}")
            
            cursor.close()
            conn.close()
            return True
            
        except psycopg2.OperationalError as e:
            print(f"❌ Ошибка подключения: {e}")
        except psycopg2.Error as e:
            print(f"❌ Ошибка базы данных: {e}")
        except Exception as e:
            print(f"❌ Неожиданная ошибка: {e}")
    
    print("❌ Не удалось подключиться ни к одной базе данных")
    return False

if __name__ == "__main__":
    print("🔍 Тестирование подключения к базе данных...")
    success = test_connection()
    
    if success:
        print("\n✅ Подключение к базе данных успешно!")
        print("Теперь можно запустить init_activity_data.py")
    else:
        print("\n❌ Проблемы с подключением к базе данных")
        print("Проверьте:")
        print("1. Запущена ли база данных PostgreSQL")
        print("2. Правильность параметров подключения")
        print("3. Доступность порта 5432")
