import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_full_quest_structure():
    print("🔍 Проверяем полную структуру таблицы quest...")

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
            print("  🔍 Проверяем полную структуру таблицы quest...")

            # Проверяем все колонки с их типами
            result = await sess.execute(text("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns
                WHERE table_name = 'quest' AND table_schema = 'public'
                ORDER BY ordinal_position
            """))
            
            columns = result.fetchall()
            print(f"    📋 Полная структура таблицы quest:")
            for col in columns:
                print(f"      - {col[0]}: {col[1]} (nullable: {col[2]}, default: {col[3]})")

            print("\n  🔍 Проверяем последние созданные квесты...")

            # Проверяем последние квесты
            result = await sess.execute(text("""
                SELECT id, name, description, image, created_at
                FROM quest
                ORDER BY created_at DESC
                LIMIT 10
            """))
            
            recent_quests = result.fetchall()
            print(f"    📋 Последние 10 квестов:")
            for quest in recent_quests:
                print(f"      - ID: {quest[0]}, Name: {quest[1]}, Created: {quest[4]}")

            print("\n  🔍 Ищем квест с названием 'test20'...")

            # Ищем конкретный квест
            result = await sess.execute(text("""
                SELECT id, name, description, image, created_at
                FROM quest
                WHERE name = 'test20'
            """))
            
            test20_quest = result.fetchone()
            if test20_quest:
                print(f"    ✅ Квест 'test20' найден: {test20_quest}")
            else:
                print("    ❌ Квест 'test20' НЕ найден!")

            print("\n  🔍 Проверяем, есть ли квесты с похожими названиями...")

            # Ищем похожие названия
            result = await sess.execute(text("""
                SELECT id, name, description, image, created_at
                FROM quest
                WHERE name LIKE '%test%'
                ORDER BY created_at DESC
            """))
            
            test_like_quests = result.fetchall()
            print(f"    📋 Квесты с 'test' в названии:")
            for quest in test_like_quests:
                print(f"      - ID: {quest[0]}, Name: {quest[1]}, Created: {quest[4]}")

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем полную структуру таблицы quest...")
    await check_full_quest_structure()

if __name__ == "__main__":
    asyncio.run(main())

























