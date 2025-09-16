#!/usr/bin/env python3
"""
Скрипт для настройки базы данных QuestCity
Создает таблицы и заполняет их базовыми данными
"""

import psycopg2
import os
from pathlib import Path

def setup_database():
    """Настройка базы данных"""
    
    # Параметры подключения
    connection_params = {
        'host': 'localhost',
        'port': 5432,
        'database': 'questcity',
        'user': 'postgres',
        'password': 'postgres'
    }
    
    try:
        print("🔍 Подключение к базе данных...")
        conn = psycopg2.connect(**connection_params)
        cursor = conn.cursor()
        
        print("✅ Подключение успешно!")
        
        # Читаем SQL скрипт
        sql_file = Path(__file__).parent / "create_tables.sql"
        if sql_file.exists():
            print("📖 Читаем SQL скрипт...")
            with open(sql_file, 'r', encoding='utf-8') as f:
                sql_script = f.read()
            
            # Выполняем SQL скрипт
            print("🚀 Создаем таблицы...")
            cursor.execute(sql_script)
            conn.commit()
            print("✅ Таблицы созданы успешно!")
        else:
            print("❌ Файл create_tables.sql не найден!")
            return False
        
        # Создаем базовые данные
        print("\n📝 Создаем базовые данные...")
        
        # Базовые активности
        activities = [
            "Face verification",
            "Photo taking", 
            "QR code scanning",
            "GPS location check",
            "Text input",
            "Audio recording",
            "Video recording",
            "Object detection",
            "Gesture recognition",
            "Document scan"
        ]
        
        print("  🎯 Создаем активности...")
        for i, activity_name in enumerate(activities, 1):
            cursor.execute(
                "INSERT INTO activity (id, name) VALUES (%s, %s) ON CONFLICT (id) DO NOTHING",
                (i, activity_name)
            )
            print(f"    ✅ {i}: {activity_name}")
        
        # Базовые категории
        categories = [
            ("Adventure", "https://example.com/adventure.jpg"),
            ("Mystery", "https://example.com/mystery.jpg"),
            ("Historical", "https://example.com/historical.jpg"),
            ("Nature", "https://example.com/nature.jpg"),
            ("Urban", "https://example.com/urban.jpg"),
            ("Cultural", "https://example.com/cultural.jpg"),
            ("Educational", "https://example.com/educational.jpg"),
            ("Entertainment", "https://example.com/entertainment.jpg")
        ]
        
        print("  🏷️  Создаем категории...")
        for i, (category_name, image_url) in enumerate(categories, 1):
            cursor.execute(
                "INSERT INTO category (id, name, image) VALUES (%s, %s, %s) ON CONFLICT (id) DO NOTHING",
                (i, category_name, image_url)
            )
            print(f"    ✅ {i}: {category_name}")
        
        # Базовые места
        places = [
            "City Center",
            "Park",
            "Museum",
            "Shopping Mall",
            "Restaurant",
            "Historical Site",
            "Beach",
            "Mountain",
            "Forest",
            "University"
        ]
        
        print("  📍 Создаем места...")
        for i, place_name in enumerate(places, 1):
            cursor.execute(
                "INSERT INTO place (id, name) VALUES (%s, %s) ON CONFLICT (id) DO NOTHING",
                (i, place_name)
            )
            print(f"    ✅ {i}: {place_name}")
        
        # Базовые инструменты
        tools = [
            ("Rangefinder", "https://example.com/rangefinder.jpg"),
            ("QR Scanner", "https://example.com/qr-scanner.jpg"),
            ("Camera", "https://example.com/camera.jpg"),
            ("GPS Device", "https://example.com/gps.jpg"),
            ("Audio Recorder", "https://example.com/audio.jpg"),
            ("Video Camera", "https://example.com/video.jpg"),
            ("Document Scanner", "https://example.com/scanner.jpg"),
            ("Gesture Sensor", "https://example.com/gesture.jpg"),
            ("Object Detector", "https://example.com/detector.jpg"),
            ("Text Input Device", "https://example.com/text-input.jpg")
        ]
        
        print("  🔧 Создаем инструменты...")
        for i, (tool_name, image_url) in enumerate(tools, 1):
            cursor.execute(
                "INSERT INTO tool (id, name, image) VALUES (%s, %s, %s) ON CONFLICT (id) DO NOTHING",
                (i, tool_name, image_url)
            )
            print(f"    ✅ {i}: {tool_name}")
        
        # Базовые типы транспорта
        vehicles = [
            "On Foot",
            "Bicycle", 
            "Car",
            "Public Transport",
            "Motorcycle",
            "Scooter"
        ]
        
        print("  🚗 Создаем типы транспорта...")
        for i, vehicle_name in enumerate(vehicles, 1):
            cursor.execute(
                "INSERT INTO vehicle (id, name) VALUES (%s, %s) ON CONFLICT (id) DO NOTHING",
                (i, vehicle_name)
            )
            print(f"    ✅ {i}: {vehicle_name}")
        
        # Создаем тестовый профиль
        print("  👤 Создаем тестовый профиль...")
        cursor.execute(
            "INSERT INTO profile (id, instagram_username, credits) VALUES (1, 'test_user', 100) ON CONFLICT (id) DO NOTHING"
        )
        print("    ✅ Тестовый профиль создан")
        
        # Коммитим все изменения
        conn.commit()
        print("\n✅ Все базовые данные созданы успешно!")
        
        # Показываем результат
        print("\n📊 Проверяем созданные данные...")
        
        cursor.execute("SELECT COUNT(*) FROM activity")
        activity_count = cursor.fetchone()[0]
        print(f"  🎯 Активностей: {activity_count}")
        
        cursor.execute("SELECT COUNT(*) FROM category")
        category_count = cursor.fetchone()[0]
        print(f"  🏷️  Категорий: {category_count}")
        
        cursor.execute("SELECT COUNT(*) FROM place")
        place_count = cursor.fetchone()[0]
        print(f"  📍 Мест: {place_count}")
        
        cursor.execute("SELECT COUNT(*) FROM tool")
        tool_count = cursor.fetchone()[0]
        print(f"  🔧 Инструментов: {tool_count}")
        
        cursor.execute("SELECT COUNT(*) FROM vehicle")
        vehicle_count = cursor.fetchone()[0]
        print(f"  🚗 Типов транспорта: {vehicle_count}")
        
        cursor.close()
        conn.close()
        
        print("\n🎉 База данных настроена успешно!")
        print("Теперь можно запускать приложение и создавать квесты!")
        
        return True
        
    except Exception as e:
        print(f"❌ Ошибка при настройке базы данных: {e}")
        if 'conn' in locals():
            conn.rollback()
            conn.close()
        return False

if __name__ == "__main__":
    print("🎯 Настройка базы данных QuestCity...")
    print("=" * 60)
    
    success = setup_database()
    
    if success:
        print("\n" + "=" * 60)
        print("🎉 Настройка завершена успешно!")
    else:
        print("\n" + "=" * 60)
        print("❌ Настройка завершилась с ошибками!")
        exit(1)
