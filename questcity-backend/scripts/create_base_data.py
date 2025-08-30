#!/usr/bin/env python3
"""
Скрипт для создания базовых справочных данных QuestCity Backend.

Создает:
- Базовые активности (activity)
- Базовые инструменты (tool) 
- Базовые транспортные средства (vehicle)
- Базовые категории квестов (category)

Использование:
    python3 scripts/create_base_data.py [--force] [--dry-run]

Опции:
    --force     Перезаписать существующие данные
    --dry-run   Показать что будет создано без изменений
"""

import argparse
import asyncio
import sys
from pathlib import Path

# Добавляем путь к src для импортов
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from db.engine import async_session_factory
from db.models.quest.point import Activity, Tool
from db.models.quest.quest import Place, Vehicle, Category
from logger import logger

# Базовые данные для инициализации
BASE_ACTIVITIES = [
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

BASE_TOOLS = [
    {"name": "Smartphone", "image": "https://example.com/smartphone.png"},
    {"name": "Camera", "image": "https://example.com/camera.png"},
    {"name": "QR Scanner", "image": "https://example.com/qr_scanner.png"},
    {"name": "GPS Tracker", "image": "https://example.com/gps.png"},
    {"name": "Voice Recorder", "image": "https://example.com/recorder.png"},
    {"name": "Compass", "image": "https://example.com/compass.png"},
    {"name": "Measuring Tape", "image": "https://example.com/tape.png"},
    {"name": "Flashlight", "image": "https://example.com/flashlight.png"},
    {"name": "Binoculars", "image": "https://example.com/binoculars.png"},
    {"name": "Notebook", "image": "https://example.com/notebook.png"}
]

BASE_VEHICLES = [
    "Walking",
    "Bicycle", 
    "Car",
    "Public Transport",
    "Motorcycle",
    "Scooter",
    "Boat",
    "Train",
    "Bus",
    "Metro"
]

BASE_PLACES = [
    "Москва",
    "Санкт-Петербург", 
    "Казань",
    "Сочи",
    "Екатеринбург",
    "Новосибирск",
    "Красноярск",
    "Самара",
    "Уфа",
    "Ростов-на-Дону"
]

BASE_CATEGORIES = [
    {"name": "Adventure", "image": "https://example.com/adventure.png"},
    {"name": "Culture", "image": "https://example.com/culture.png"},
    {"name": "Sport", "image": "https://example.com/sport.png"},
    {"name": "Education", "image": "https://example.com/education.png"},
    {"name": "Entertainment", "image": "https://example.com/entertainment.png"},
    {"name": "Business", "image": "https://example.com/business.png"},
    {"name": "Travel", "image": "https://example.com/travel.png"},
    {"name": "Technology", "image": "https://example.com/technology.png"},
    {"name": "Nature", "image": "https://example.com/nature.png"},
    {"name": "Social", "image": "https://example.com/social.png"}
]


class BaseDataCreator:
    """Класс для создания базовых справочных данных."""
    
    def __init__(self, session: AsyncSession, force: bool = False, dry_run: bool = False):
        self.session = session
        self.force = force
        self.dry_run = dry_run
        self.created_count = 0
        self.skipped_count = 0

    async def create_activities(self) -> None:
        """Создание базовых активностей."""
        logger.info("🎯 Создание базовых активностей...")
        
        existing = await self.session.execute(select(Activity.name))
        existing_names = {row[0] for row in existing.fetchall()}
        
        for activity_name in BASE_ACTIVITIES:
            if activity_name in existing_names and not self.force:
                logger.debug(f"⏭️  Активность '{activity_name}' уже существует")
                self.skipped_count += 1
                continue
                
            if self.dry_run:
                logger.info(f"🔍 [DRY-RUN] Создана активность: {activity_name}")
                continue
            
            # Удаляем существующую если force=True
            if activity_name in existing_names and self.force:
                existing_activity = await self.session.execute(
                    select(Activity).where(Activity.name == activity_name)
                )
                activity_to_delete = existing_activity.scalar_one_or_none()
                if activity_to_delete:
                    await self.session.delete(activity_to_delete)
                    logger.debug(f"🗑️  Удалена существующая активность: {activity_name}")
            
            activity = Activity(name=activity_name)
            self.session.add(activity)
            logger.info(f"✅ Создана активность: {activity_name}")
            self.created_count += 1

    async def create_tools(self) -> None:
        """Создание базовых инструментов."""
        logger.info("🔧 Создание базовых инструментов...")
        
        existing = await self.session.execute(select(Tool.name))
        existing_names = {row[0] for row in existing.fetchall()}
        
        for tool_data in BASE_TOOLS:
            tool_name = tool_data["name"]
            
            if tool_name in existing_names and not self.force:
                logger.debug(f"⏭️  Инструмент '{tool_name}' уже существует")
                self.skipped_count += 1
                continue
                
            if self.dry_run:
                logger.info(f"🔍 [DRY-RUN] Создан инструмент: {tool_name}")
                continue
            
            # Удаляем существующий если force=True
            if tool_name in existing_names and self.force:
                existing_tool = await self.session.execute(
                    select(Tool).where(Tool.name == tool_name)
                )
                tool_to_delete = existing_tool.scalar_one_or_none()
                if tool_to_delete:
                    await self.session.delete(tool_to_delete)
                    logger.debug(f"🗑️  Удален существующий инструмент: {tool_name}")
            
            tool = Tool(name=tool_name, image=tool_data["image"])
            self.session.add(tool)
            logger.info(f"✅ Создан инструмент: {tool_name}")
            self.created_count += 1

    async def create_vehicles(self) -> None:
        """Создание базовых транспортных средств."""
        logger.info("🚗 Создание базовых транспортных средств...")
        
        existing = await self.session.execute(select(Vehicle.name))
        existing_names = {row[0] for row in existing.fetchall()}
        
        for vehicle_name in BASE_VEHICLES:
            if vehicle_name in existing_names and not self.force:
                logger.debug(f"⏭️  Транспорт '{vehicle_name}' уже существует")
                self.skipped_count += 1
                continue
                
            if self.dry_run:
                logger.info(f"🔍 [DRY-RUN] Создан транспорт: {vehicle_name}")
                continue
            
            # Удаляем существующий если force=True
            if vehicle_name in existing_names and self.force:
                existing_vehicle = await self.session.execute(
                    select(Vehicle).where(Vehicle.name == vehicle_name)
                )
                vehicle_to_delete = existing_vehicle.scalar_one_or_none()
                if vehicle_to_delete:
                    await self.session.delete(vehicle_to_delete)
                    logger.debug(f"🗑️  Удален существующий транспорт: {vehicle_name}")
            
            vehicle = Vehicle(name=vehicle_name)
            self.session.add(vehicle)
            logger.info(f"✅ Создан транспорт: {vehicle_name}")
            self.created_count += 1

    async def create_places(self) -> None:
        """Создание базовых мест."""
        logger.info("📍 Создание базовых мест...")
        
        existing = await self.session.execute(select(Place.name))
        existing_names = {row[0] for row in existing.fetchall()}
        
        for place_name in BASE_PLACES:
            if place_name in existing_names and not self.force:
                logger.debug(f"⏭️  Место '{place_name}' уже существует")
                self.skipped_count += 1
                continue
                
            if self.dry_run:
                logger.info(f"🔍 [DRY-RUN] Создано место: {place_name}")
                continue
            
            # Удаляем существующее если force=True
            if place_name in existing_names and self.force:
                existing_place = await self.session.execute(
                    select(Place).where(Place.name == place_name)
                )
                place_to_delete = existing_place.scalar_one_or_none()
                if place_to_delete:
                    await self.session.delete(place_to_delete)
                    logger.debug(f"🗑️  Удалено существующее место: {place_name}")
            
            place = Place(name=place_name)
            self.session.add(place)
            logger.info(f"✅ Создано место: {place_name}")
            self.created_count += 1

    async def create_categories(self) -> None:
        """Создание базовых категорий."""
        logger.info("📂 Создание базовых категорий...")
        
        existing = await self.session.execute(select(Category.name))
        existing_names = {row[0] for row in existing.fetchall()}
        
        for category_data in BASE_CATEGORIES:
            category_name = category_data["name"]
            
            if category_name in existing_names and not self.force:
                logger.debug(f"⏭️  Категория '{category_name}' уже существует")
                self.skipped_count += 1
                continue
                
            if self.dry_run:
                logger.info(f"🔍 [DRY-RUN] Создана категория: {category_name}")
                continue
            
            # Удаляем существующую если force=True
            if category_name in existing_names and self.force:
                existing_category = await self.session.execute(
                    select(Category).where(Category.name == category_name)
                )
                category_to_delete = existing_category.scalar_one_or_none()
                if category_to_delete:
                    await self.session.delete(category_to_delete)
                    logger.debug(f"🗑️  Удалена существующая категория: {category_name}")
            
            category = Category(name=category_name, image=category_data["image"])
            self.session.add(category)
            logger.info(f"✅ Создана категория: {category_name}")
            self.created_count += 1

    async def create_all(self) -> None:
        """Создание всех базовых данных."""
        logger.info("🚀 Начинаем создание базовых справочных данных...")
        
        try:
            await self.create_activities()
            await self.create_tools()
            await self.create_vehicles()
            await self.create_places()
            await self.create_categories()
            
            if not self.dry_run:
                await self.session.commit()
                logger.info("✅ Все изменения сохранены в базе данных")
            else:
                logger.info("🔍 [DRY-RUN] Изменения НЕ были сохранены")
                
        except Exception as e:
            if not self.dry_run:
                await self.session.rollback()
                logger.error(f"❌ Ошибка при создании данных: {e}")
                raise
            else:
                logger.error(f"❌ [DRY-RUN] Ошибка: {e}")
                raise

        logger.info(f"📊 Итоги: создано {self.created_count}, пропущено {self.skipped_count}")


async def main():
    """Главная функция."""
    parser = argparse.ArgumentParser(description="Создание базовых справочных данных")
    parser.add_argument("--force", action="store_true", 
                       help="Перезаписать существующие данные")
    parser.add_argument("--dry-run", action="store_true",
                       help="Показать что будет создано без изменений")
    
    args = parser.parse_args()
    
    logger.info("🔧 QuestCity Backend - Создание базовых данных")
    
    if args.dry_run:
        logger.info("🔍 Режим DRY-RUN: изменения НЕ будут сохранены")
    
    if args.force:
        logger.info("⚠️  Режим FORCE: существующие данные будут перезаписаны")
    
    try:
        async with async_session_factory() as session:
            creator = BaseDataCreator(session, force=args.force, dry_run=args.dry_run)
            await creator.create_all()
            
        logger.info("🎉 Базовые данные успешно созданы!")
        
    except Exception as e:
        logger.error(f"❌ Критическая ошибка: {e}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main()) 