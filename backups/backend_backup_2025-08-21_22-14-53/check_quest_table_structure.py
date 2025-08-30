import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_quest_table_structure():
    print("🔍 Проверяем реальную структуру таблицы quest...")

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
            print("  🔍 Проверяем все таблицы в базе данных...")

            # Проверяем все таблицы
            result = await sess.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """))
            
            tables = result.fetchall()
            print(f"    📋 Всего таблиц: {len(tables)}")
            for table in tables:
                print(f"      - {table[0]}")

            print("\n  🔍 Проверяем структуру таблицы quest...")

            # Проверяем структуру таблицы quest
            result = await sess.execute(text("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns
                WHERE table_name = 'quest' AND table_schema = 'public'
                ORDER BY ordinal_position
            """))
            
            columns = result.fetchall()
            if columns:
                print(f"    📋 Структура таблицы quest:")
                for col in columns:
                    print(f"      - {col[0]}: {col[1]} (nullable: {col[2]}, default: {col[3]})")
            else:
                print("    ❌ Таблица quest не найдена!")

            print("\n  🔍 Проверяем все данные в таблице quest...")

            # Проверяем все данные в таблице quest
            try:
                result = await sess.execute(text("SELECT * FROM quest LIMIT 5"))
                quests = result.fetchall()
                print(f"    📋 Первые 5 записей в таблице quest:")
                for quest in quests:
                    print(f"      - {quest}")
            except Exception as e:
                print(f"    ❌ Ошибка при чтении данных: {e}")

            print("\n  🔍 Проверяем, есть ли таблица с похожим названием...")

            # Ищем таблицы с похожими названиями
            result = await sess.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name LIKE '%quest%'
                ORDER BY table_name
            """))
            
            quest_like_tables = result.fetchall()
            print(f"    📋 Таблицы с 'quest' в названии:")
            for table in quest_like_tables:
                print(f"      - {table[0]}")

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем структуру таблицы quest...")
    await check_quest_table_structure()

if __name__ == "__main__":
    asyncio.run(main())











