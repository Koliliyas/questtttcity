#!/usr/bin/env python3
"""
Скрипт для создания тестового инструмента с ID 1
"""

import asyncio
from sqlalchemy import create_engine, text
from sqlalchemy.ext.asyncio import create_async_engine

# Параметры подключения к базе данных
DATABASE_URL = "postgresql+asyncpg://postgres:postgres@localhost:5432/questcity_db"

async def create_test_tool():
    """Создаем тестовый инструмент с ID 1"""
    
    # Создаем асинхронное подключение
    engine = create_async_engine(DATABASE_URL, echo=True)
    
    async with engine.begin() as conn:
        # Проверим, есть ли уже инструмент с ID 1
        check_query = text("SELECT COUNT(*) FROM tool WHERE id = 1")
        check_result = await conn.execute(check_query)
        count = check_result.scalar()
        
        if count > 0:
            print("✅ Инструмент с ID 1 уже существует!")
            return
        
        # Создаем тестовый инструмент
        create_query = text("""
            INSERT INTO tool (id, name) 
            VALUES (1, 'Test Tool')
        """)
        
        await conn.execute(create_query)
        print("✅ Тестовый инструмент с ID 1 создан!")
        
        # Проверим, что создался
        verify_query = text("SELECT id, name FROM tool WHERE id = 1")
        verify_result = await conn.execute(verify_query)
        tool = verify_result.fetchone()
        
        if tool:
            print(f"✅ Подтверждение: ID {tool.id}, Название: {tool.name}")
        else:
            print("❌ Ошибка: инструмент не создался")
    
    await engine.dispose()

if __name__ == "__main__":
    print("🚀 Создаем тестовый инструмент...")
    asyncio.run(create_test_tool())
    print("✅ Запрос завершен!")






