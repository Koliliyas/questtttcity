import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text, inspect

async def check_activity_table():
    print("🔍 Проверяем таблицу activity напрямую...")
    try:
        # Используем ТОЧНО ТАКУЮ ЖЕ конфигурацию, как в FastAPI
        engine = create_async_engine(
            'postgresql+asyncpg://postgres:postgres@localhost/questcity',
            echo=True
        )
        
        async_session = sessionmaker(
            engine, 
            class_=AsyncSession, 
            expire_on_commit=False
        )
        
        async with async_session() as session:
            print("  ✅ Сессия создана успешно")
            
            # Проверяем структуру таблицы
            print("  🔍 Проверяем структуру таблицы...")
            result = await session.execute(text("""
                SELECT table_name, table_schema 
                FROM information_schema.tables 
                WHERE table_name = 'activity'
            """))
            table_info = result.fetchone()
            print(f"    Информация о таблице: {table_info}")
            
            # Проверяем все записи в таблице
            print("  🔍 Проверяем все записи в activity...")
            result = await session.execute(text("SELECT * FROM activity"))
            all_rows = result.fetchall()
            print(f"    Всего записей: {len(all_rows)}")
            print(f"    Все записи: {all_rows}")
            
            # Проверяем конкретную запись с ID = 1
            print("  🔍 Проверяем запись с ID = 1...")
            result = await session.execute(text("SELECT * FROM activity WHERE id = 1"))
            row = result.fetchone()
            print(f"    Запись с ID = 1: {row}")
            
            # Проверяем минимальный и максимальный ID
            print("  🔍 Проверяем диапазон ID...")
            result = await session.execute(text("SELECT MIN(id), MAX(id) FROM activity"))
            min_max = result.fetchone()
            print(f"    Минимальный и максимальный ID: {min_max}")
            
            # Проверяем права доступа
            print("  🔍 Проверяем права доступа...")
            result = await session.execute(text("""
                SELECT grantee, privilege_type 
                FROM information_schema.role_table_grants 
                WHERE table_name = 'activity'
            """))
            grants = result.fetchall()
            print(f"    Права доступа: {grants}")
            
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем таблицу activity...")
    await check_activity_table()

if __name__ == "__main__":
    asyncio.run(main())
















