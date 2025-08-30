#!/usr/bin/env python3
"""
Скрипт для получения списка всех инструментов из базы данных
"""

import asyncio
from sqlalchemy import create_engine, text
from sqlalchemy.ext.asyncio import create_async_engine

# Параметры подключения к базе данных
DATABASE_URL = "postgresql+asyncpg://postgres:postgres@localhost:5432/questcity_db"

async def get_tools_list():
    """Получаем список всех инструментов из базы"""
    
    # Создаем асинхронное подключение
    engine = create_async_engine(DATABASE_URL, echo=True)
    
    async with engine.begin() as conn:
        # Получаем все инструменты
        tools_query = text("""
            SELECT 
                t.id,
                t.name
            FROM tool t
            ORDER BY t.id
        """)
        
        tools_result = await conn.execute(tools_query)
        tools_data = tools_result.fetchall()
        
        print(f"🔍 ИНСТРУМЕНТЫ (найдено: {len(tools_data)}):")
        for i, tool in enumerate(tools_data):
            print(f"\n--- Инструмент {i+1} ---")
            print(f"ID: {tool.id}")
            print(f"Название: {tool.name}")
        
        # Если инструментов нет, попробуем другие таблицы
        if not tools_data:
            print("\n🔍 Попробуем найти таблицу с инструментами...")
            
            # Проверим структуру базы
            tables_query = text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name LIKE '%tool%'
                ORDER BY table_name
            """)
            
            tables_result = await conn.execute(tables_query)
            tables_data = tables_result.fetchall()
            
            print(f"Таблицы с 'tool' в названии: {[t[0] for t in tables_data]}")
            
            # Попробуем таблицу tools (множественное число)
            if any('tools' in t[0] for t in tables_data):
                tools_query = text("""
                    SELECT 
                        t.id,
                        t.name,
                        t.description
                    FROM tools t
                    ORDER BY t.id
                """)
                
                tools_result = await conn.execute(tools_query)
                tools_data = tools_result.fetchall()
                
                print(f"\n🔍 ИНСТРУМЕНТЫ из таблицы 'tools' (найдено: {len(tools_data)}):")
                for i, tool in enumerate(tools_data):
                    print(f"\n--- Инструмент {i+1} ---")
                    print(f"ID: {tool.id}")
                    print(f"Название: {tool.name}")
                    print(f"Описание: {tool.description}")
    
    await engine.dispose()

if __name__ == "__main__":
    print("🚀 Запускаем получение списка инструментов...")
    asyncio.run(get_tools_list())
    print("✅ Запрос завершен!")
