#!/usr/bin/env python3
"""
Скрипт для проверки merchandise данных в базе данных
"""

import asyncio
import os
import sys
from sqlalchemy import create_engine, text, select
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

# Добавляем путь к модулям проекта
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

async def check_merchandise_data():
    """Проверяем merchandise данные в базе данных"""
    
    # Получаем переменные окружения
    database_url = os.getenv('DATABASE_URL', 'postgresql+asyncpg://postgres:postgres@localhost:5432/questcity_db')
    
    print("🔍 Проверка merchandise данных в базе данных")
    print(f"📊 DATABASE_URL: {database_url}")
    
    try:
        # Создаем асинхронное подключение к БД
        engine = create_async_engine(database_url, echo=False)
        
        async with engine.begin() as conn:
            print("\n📋 Проверяем структуру таблиц...")
            
            # Проверяем таблицу quest
            result = await conn.execute(text("""
                SELECT column_name, data_type, is_nullable 
                FROM information_schema.columns 
                WHERE table_name = 'quest' 
                ORDER BY ordinal_position
            """))
            quest_columns = result.fetchall()
            
            print("📊 Таблица 'quest':")
            for col in quest_columns:
                print(f"  - {col[0]}: {col[1]} ({'NULL' if col[2] == 'YES' else 'NOT NULL'})")
            
            # Проверяем таблицу merch
            result = await conn.execute(text("""
                SELECT column_name, data_type, is_nullable 
                FROM information_schema.columns 
                WHERE table_name = 'merch' 
                ORDER BY ordinal_position
            """))
            merch_columns = result.fetchall()
            
            print("\n📊 Таблица 'merch':")
            for col in merch_columns:
                print(f"  - {col[0]}: {col[1]} ({'NULL' if col[2] == 'YES' else 'NOT NULL'})")
            
            # Проверяем количество квестов
            result = await conn.execute(text("SELECT COUNT(*) FROM quest"))
            quest_count = result.scalar()
            print(f"\n📊 Всего квестов в БД: {quest_count}")
            
            # Проверяем количество merchandise записей
            result = await conn.execute(text("SELECT COUNT(*) FROM merch"))
            merch_count = result.scalar()
            print(f"📊 Всего merchandise записей в БД: {merch_count}")
            
            # Показываем последние квесты
            result = await conn.execute(text("""
                SELECT id, name, mentor_preference, created_at 
                FROM quest 
                ORDER BY created_at DESC 
                LIMIT 5
            """))
            recent_quests = result.fetchall()
            
            print(f"\n📊 Последние 5 квестов:")
            for quest in recent_quests:
                print(f"  - ID: {quest[0]}, Name: '{quest[1]}', Mentor: '{quest[2]}', Created: {quest[3]}")
                
                # Проверяем merchandise для каждого квеста
                merch_result = await conn.execute(text("""
                    SELECT id, description, price, image 
                    FROM merch 
                    WHERE quest_id = :quest_id
                """), {"quest_id": quest[0]})
                merch_items = merch_result.fetchall()
                
                if merch_items:
                    print(f"    📦 Merchandise ({len(merch_items)} items):")
                    for merch in merch_items:
                        print(f"      - ID: {merch[0]}, Desc: '{merch[1]}', Price: {merch[2]}, Image: {merch[3][:50]}...")
                else:
                    print(f"    📦 Merchandise: НЕТ ДАННЫХ")
            
            # Проверяем все merchandise записи
            if merch_count > 0:
                print(f"\n📊 Все merchandise записи:")
                result = await conn.execute(text("""
                    SELECT m.id, m.description, m.price, m.image, m.quest_id, q.name as quest_name
                    FROM merch m
                    JOIN quest q ON m.quest_id = q.id
                    ORDER BY m.id DESC
                """))
                all_merch = result.fetchall()
                
                for merch in all_merch:
                    print(f"  - ID: {merch[0]}, Quest: '{merch[5]}' (ID: {merch[4]}), Desc: '{merch[1]}', Price: {merch[2]}")
            
            # Проверяем квесты с mentor_preference
            result = await conn.execute(text("""
                SELECT id, name, mentor_preference 
                FROM quest 
                WHERE mentor_preference IS NOT NULL AND mentor_preference != ''
                ORDER BY id DESC
            """))
            mentor_quests = result.fetchall()
            
            print(f"\n📊 Квесты с mentor_preference ({len(mentor_quests)}):")
            for quest in mentor_quests:
                print(f"  - ID: {quest[0]}, Name: '{quest[1]}', Mentor: '{quest[2]}'")
            
            # Проверяем квесты без merchandise
            result = await conn.execute(text("""
                SELECT q.id, q.name
                FROM quest q
                LEFT JOIN merch m ON q.id = m.quest_id
                WHERE m.id IS NULL
                ORDER BY q.id DESC
            """))
            quests_without_merch = result.fetchall()
            
            print(f"\n📊 Квесты БЕЗ merchandise ({len(quests_without_merch)}):")
            for quest in quests_without_merch:
                print(f"  - ID: {quest[0]}, Name: '{quest[1]}'")
            
            # Проверяем квесты с merchandise
            result = await conn.execute(text("""
                SELECT DISTINCT q.id, q.name, COUNT(m.id) as merch_count
                FROM quest q
                JOIN merch m ON q.id = m.quest_id
                GROUP BY q.id, q.name
                ORDER BY q.id DESC
            """))
            quests_with_merch = result.fetchall()
            
            print(f"\n📊 Квесты С merchandise ({len(quests_with_merch)}):")
            for quest in quests_with_merch:
                print(f"  - ID: {quest[0]}, Name: '{quest[1]}', Merch count: {quest[2]}")
        
        await engine.dispose()
        
    except Exception as e:
        print(f"❌ Ошибка при проверке БД: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(check_merchandise_data())
