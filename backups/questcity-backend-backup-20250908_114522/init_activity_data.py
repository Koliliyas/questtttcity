#!/usr/bin/env python3
"""
Скрипт для инициализации базовых данных в таблице activity.
Это необходимо для корректной работы создания квестов.
"""

import asyncio
import os
import sys
from pathlib import Path

# Добавляем корневую директорию в PYTHONPATH
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

# Получаем строку подключения к БД
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/questcity")

async def init_activity_data():
    """Инициализация базовых данных в таблице activity."""
    
    print("🚀 Инициализация базовых данных в таблице activity...")
    
    # Создаем подключение к БД
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    try:
        with SessionLocal() as session:
            # Проверяем, есть ли уже данные в таблице activity
            result = session.execute(text("SELECT COUNT(*) FROM activity"))
            count = result.scalar()
            
            if count > 0:
                print(f"✅ В таблице activity уже есть {count} записей")
                return
            
            # Создаем базовые активности
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
            
            print(f"📝 Создаем {len(activities)} базовых активностей...")
            
            for i, activity_name in enumerate(activities, 1):
                # Проверяем, не существует ли уже такая активность
                existing = session.execute(
                    text("SELECT id FROM activity WHERE name = :name"),
                    {"name": activity_name}
                ).scalar()
                
                if existing:
                    print(f"  ⏭️  Активность '{activity_name}' уже существует (ID: {existing})")
                    continue
                
                # Создаем новую активность
                session.execute(
                    text("INSERT INTO activity (id, name) VALUES (:id, :name)"),
                    {"id": i, "name": activity_name}
                )
                print(f"  ✅ Создана активность '{activity_name}' (ID: {i})")
            
            # Коммитим изменения
            session.commit()
            print("✅ Все базовые активности успешно созданы!")
            
            # Показываем результат
            result = session.execute(text("SELECT id, name FROM activity ORDER BY id"))
            activities = result.fetchall()
            
            print("\n📋 Список созданных активностей:")
            for activity_id, name in activities:
                print(f"  {activity_id:2d}: {name}")
                
    except Exception as e:
        print(f"❌ Ошибка при инициализации данных: {e}")
        session.rollback()
        raise
    finally:
        engine.dispose()

async def init_tool_data():
    """Инициализация базовых данных в таблице tool."""
    
    print("\n🔧 Инициализация базовых данных в таблице tool...")
    
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    try:
        with SessionLocal() as session:
            # Проверяем, есть ли уже данные
            result = session.execute(text("SELECT COUNT(*) FROM tool"))
            count = result.scalar()
            
            if count > 0:
                print(f"✅ В таблице tool уже есть {count} записей")
                return
            
            # Создаем базовые инструменты
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
            
            print(f"📝 Создаем {len(tools)} базовых инструментов...")
            
            for i, (tool_name, image_url) in enumerate(tools, 1):
                existing = session.execute(
                    text("SELECT id FROM tool WHERE name = :name"),
                    {"name": tool_name}
                ).scalar()
                
                if existing:
                    print(f"  ⏭️  Инструмент '{tool_name}' уже существует (ID: {existing})")
                    continue
                
                session.execute(
                    text("INSERT INTO tool (id, name, image) VALUES (:id, :name, :image)"),
                    {"id": i, "name": tool_name, "image": image_url}
                )
                print(f"  ✅ Создан инструмент '{tool_name}' (ID: {i})")
            
            session.commit()
            print("✅ Все базовые инструменты успешно созданы!")
            
    except Exception as e:
        print(f"❌ Ошибка при инициализации инструментов: {e}")
        session.rollback()
        raise
    finally:
        engine.dispose()

async def init_category_data():
    """Инициализация базовых данных в таблице category."""
    
    print("\n🏷️  Инициализация базовых данных в таблице category...")
    
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    try:
        with SessionLocal() as session:
            result = session.execute(text("SELECT COUNT(*) FROM category"))
            count = result.scalar()
            
            if count > 0:
                print(f"✅ В таблице category уже есть {count} записей")
                return
            
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
            
            print(f"📝 Создаем {len(categories)} базовых категорий...")
            
            for i, (category_name, image_url) in enumerate(categories, 1):
                existing = session.execute(
                    text("SELECT id FROM category WHERE name = :name"),
                    {"name": category_name}
                ).scalar()
                
                if existing:
                    print(f"  ⏭️  Категория '{category_name}' уже существует (ID: {existing})")
                    continue
                
                session.execute(
                    text("INSERT INTO category (id, name, image) VALUES (:id, :name, :image)"),
                    {"id": i, "name": category_name, "image": image_url}
                )
                print(f"  ✅ Создана категория '{category_name}' (ID: {i})")
            
            session.commit()
            print("✅ Все базовые категории успешно созданы!")
            
    except Exception as e:
        print(f"❌ Ошибка при инициализации категорий: {e}")
        session.rollback()
        raise
    finally:
        engine.dispose()

async def init_vehicle_data():
    """Инициализация базовых данных в таблице vehicle."""
    
    print("\n🚗 Инициализация базовых данных в таблице vehicle...")
    
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    try:
        with SessionLocal() as session:
            result = session.execute(text("SELECT COUNT(*) FROM vehicle"))
            count = result.scalar()
            
            if count > 0:
                print(f"✅ В таблице vehicle уже есть {count} записей")
                return
            
            vehicles = [
                "On Foot",
                "Bicycle", 
                "Car",
                "Public Transport",
                "Motorcycle",
                "Scooter"
            ]
            
            print(f"📝 Создаем {len(vehicles)} базовых типов транспорта...")
            
            for i, vehicle_name in enumerate(vehicles, 1):
                existing = session.execute(
                    text("SELECT id FROM vehicle WHERE name = :name"),
                    {"name": vehicle_name}
                ).scalar()
                
                if existing:
                    print(f"  ⏭️  Транспорт '{vehicle_name}' уже существует (ID: {existing})")
                    continue
                
                session.execute(
                    text("INSERT INTO vehicle (id, name) VALUES (:id, :name)"),
                    {"id": i, "name": vehicle_name}
                )
                print(f"  ✅ Создан транспорт '{vehicle_name}' (ID: {i})")
            
            session.commit()
            print("✅ Все базовые типы транспорта успешно созданы!")
            
    except Exception as e:
        print(f"❌ Ошибка при инициализации транспорта: {e}")
        session.rollback()
        raise
    finally:
        engine.dispose()

async def init_place_data():
    """Инициализация базовых данных в таблице place."""
    
    print("\n📍 Инициализация базовых данных в таблице place...")
    
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    try:
        with SessionLocal() as session:
            result = session.execute(text("SELECT COUNT(*) FROM place"))
            count = result.scalar()
            
            if count > 0:
                print(f"✅ В таблице place уже есть {count} записей")
                return
            
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
            
            print(f"📝 Создаем {len(places)} базовых мест...")
            
            for i, place_name in enumerate(places, 1):
                existing = session.execute(
                    text("SELECT id FROM place WHERE name = :name"),
                    {"name": place_name}
                ).scalar()
                
                if existing:
                    print(f"  ⏭️  Место '{place_name}' уже существует (ID: {existing})")
                    continue
                
                session.execute(
                    text("INSERT INTO place (id, name) VALUES (:id, :name)"),
                    {"id": i, "name": place_name}
                )
                print(f"  ✅ Создано место '{place_name}' (ID: {i})")
            
            session.commit()
            print("✅ Все базовые места успешно созданы!")
            
    except Exception as e:
        print(f"❌ Ошибка при инициализации мест: {e}")
        session.rollback()
        raise
    finally:
        engine.dispose()

async def main():
    """Основная функция инициализации."""
    print("🎯 Инициализация базовых данных для QuestCity...")
    print("=" * 60)
    
    try:
        await init_activity_data()
        await init_tool_data()
        await init_category_data()
        await init_vehicle_data()
        await init_place_data()
        
        print("\n" + "=" * 60)
        print("🎉 Инициализация завершена успешно!")
        print("Теперь создание квестов должно работать корректно.")
        
    except Exception as e:
        print(f"\n❌ Критическая ошибка: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
