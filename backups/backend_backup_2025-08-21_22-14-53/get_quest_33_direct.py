#!/usr/bin/env python3
"""
Скрипт для прямого запроса к базе данных PostgreSQL
для получения данных о квесте test66 (ID 33)
"""

import asyncio
import os
from sqlalchemy import create_engine, text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

# Параметры подключения к базе данных
DATABASE_URL = "postgresql+asyncpg://postgres:postgres@localhost:5432/questcity_db"

async def get_quest_data():
    """Получаем данные о квесте ID 33 напрямую из базы"""
    
    # Создаем асинхронное подключение
    engine = create_async_engine(DATABASE_URL, echo=True)
    
    async with engine.begin() as conn:
        # Получаем данные квеста
        quest_query = text("""
            SELECT 
                q.id,
                q.name,
                q.description,
                q.image,
                q.mentor_preference,
                q.auto_accrual,
                q.cost,
                q.reward,
                q.category_id,
                q.vehicle_id,
                q.place_id,
                q.created_at,
                q.updated_at
            FROM quest q
            WHERE q.id = 33
        """)
        
        quest_result = await conn.execute(quest_query)
        quest_data = quest_result.fetchone()
        
        if not quest_data:
            print("❌ Квест с ID 33 не найден!")
            return
        
        print("🔍 ДАННЫЕ КВЕСТА:")
        print(f"ID: {quest_data.id}")
        print(f"Название: {quest_data.name}")
        print(f"Описание: {quest_data.description}")
        print(f"Изображение: {quest_data.image}")
        print(f"Mentor Preference: {quest_data.mentor_preference}")
        print(f"Auto Accrual: {quest_data.auto_accrual}")
        print(f"Стоимость: {quest_data.cost}")
        print(f"Награда: {quest_data.reward}")
        print(f"Категория ID: {quest_data.category_id}")
        print(f"ТС ID: {quest_data.vehicle_id}")
        print(f"Место ID: {quest_data.place_id}")
        print(f"Создан: {quest_data.created_at}")
        print(f"Обновлен: {quest_data.updated_at}")
        
        # Получаем точки квеста
        points_query = text("""
            SELECT 
                p.id,
                p.quest_id,
                p.name_of_location,
                p.description,
                p.order,
                p.type_id,
                p.tool_id,
                p.file,
                p.is_divide
            FROM point p
            WHERE p.quest_id = 33
            ORDER BY p.order
        """)
        
        points_result = await conn.execute(points_query)
        points_data = points_result.fetchall()
        
        print(f"\n🔍 ТОЧКИ КВЕСТА (найдено: {len(points_data)}):")
        for i, point in enumerate(points_data):
            print(f"\n--- Точка {i+1} ---")
            print(f"ID точки: {point.id}")
            print(f"Quest ID: {point.quest_id}")
            print(f"Название: {point.name_of_location}")
            print(f"Описание: {point.description}")
            print(f"Порядок: {point.order}")
            print(f"Тип ID: {point.type_id}")
            print(f"Инструмент ID: {point.tool_id}")
            print(f"Файл: {point.file}")
            print(f"Разделить: {point.is_divide}")
            
            # Получаем места для каждой точки
            places_query = text("""
                SELECT 
                    ps.id,
                    ps.point_id,
                    ps.longitude,
                    ps.latitude,
                    ps.detections_radius,
                    ps.height,
                    ps.interaction_inaccuracy,
                    ps.part,
                    ps.random_occurrence
                FROM place_settings ps
                WHERE ps.point_id = :point_id
                ORDER BY ps.part
            """)
            
            places_result = await conn.execute(places_query, {"point_id": point.id})
            places_data = places_result.fetchall()
            
            print(f"  Места (найдено: {len(places_data)}):")
            for j, place in enumerate(places_data):
                print(f"    --- Место {j+1} ---")
                print(f"    ID места: {place.id}")
                print(f"    Point ID: {place.point_id}")
                print(f"    Долгота: {place.longitude}")
                print(f"    Широта: {place.latitude}")
                print(f"    Радиус обнаружения: {place.detections_radius}")
                print(f"    Высота: {place.height}")
                print(f"    Неточность взаимодействия: {place.interaction_inaccuracy}")
                print(f"    Часть: {place.part}")
                print(f"    Случайное появление: {place.random_occurrence}")
    
    await engine.dispose()

if __name__ == "__main__":
    print("🚀 Запускаем прямой запрос к базе данных...")
    asyncio.run(get_quest_data())
    print("✅ Запрос завершен!")
