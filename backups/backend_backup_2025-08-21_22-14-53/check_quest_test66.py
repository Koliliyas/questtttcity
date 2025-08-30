#!/usr/bin/env python3
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_quest_test66():
    print("🔍 Ищем квест с названием 'test66'...")

    # Подключаемся к базе questcity_db
    engine = create_async_engine(
        'postgresql+asyncpg://postgres:postgres@localhost/questcity_db',
        echo=False
    )

    session = sessionmaker(
        engine,
        class_=AsyncSession,
        expire_on_commit=False
    )

    try:
        async with session() as sess:
            print("  🔍 Выполняем поиск квеста 'test66'...")

            # Ищем квест с названием test66
            result = await sess.execute(text("""
                SELECT * FROM quest WHERE name = 'test66'
            """))
            
            quest = result.fetchone()
            if quest:
                print(f"    ✅ Найден квест 'test66':")
                
                # Получаем названия колонок
                columns = result.keys()
                
                # Выводим все данные квеста
                for i, column in enumerate(columns):
                    value = quest[i]
                    print(f"      {column}: {value}")
                
                # Дополнительно получаем информацию о категории
                if quest.category_id:
                    cat_result = await sess.execute(text("""
                        SELECT name FROM category WHERE id = :category_id
                    """), {"category_id": quest.category_id})
                    
                    cat_row = cat_result.fetchone()
                    if cat_row:
                        print(f"      category_name: {cat_row[0]}")
                
                # Получаем информацию о точках квеста
                points_result = await sess.execute(text("""
                    SELECT * FROM point WHERE quest_id = :quest_id
                """), {"quest_id": quest.id})
                
                points = points_result.fetchall()
                if points:
                    print(f"\n      📍 Точки квеста ({len(points)}):")
                    for j, point in enumerate(points):
                        print(f"        Точка {j+1}:")
                        point_columns = points_result.keys()
                        for k, col in enumerate(point_columns):
                            print(f"          {col}: {point[k]}")
                else:
                    print(f"      📍 Точки квеста: нет")
                
            else:
                print("    ❌ Квест с названием 'test66' не найден!")
                
                # Показываем все квесты для справки
                all_quests_result = await sess.execute(text("""
                    SELECT id, name FROM quest ORDER BY id
                """))
                
                all_quests = all_quests_result.fetchall()
                print(f"\n    📊 Всего квестов в базе: {len(all_quests)}")
                if all_quests:
                    print("    🔍 Все квесты:")
                    for q in all_quests:
                        print(f"      - ID: {q[0]}, Название: '{q[1]}'")

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем квест 'test66'...")
    await check_quest_test66()

if __name__ == "__main__":
    asyncio.run(main())
