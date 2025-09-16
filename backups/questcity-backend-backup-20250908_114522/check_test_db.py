import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_test_db():
    print("🔍 Проверяем базу данных test...")
    try:
        # Используем настройки из .env.example
        engine = create_async_engine(
            'postgresql+asyncpg://postgres:postgres@localhost/test',
            echo=True
        )
        
        async_session = sessionmaker(
            engine, 
            class_=AsyncSession, 
            expire_on_commit=False
        )
        
        async with async_session() as session:
            print("  ✅ Сессия создана успешно")
            
            # Проверяем текущую схему
            print("  🔍 Проверяем текущую схему...")
            result = await session.execute(text("SELECT current_schema()"))
            schema = result.scalar()
            print(f"    Текущая схема: {schema}")
            
            # Проверяем все таблицы в схеме public
            print("  🔍 Проверяем все таблицы в схеме public...")
            result = await session.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' 
                ORDER BY table_name
            """))
            public_tables = result.fetchall()
            print(f"    Таблицы в public: {[t[0] for t in public_tables]}")
            
            # Проверяем таблицу activity
            print("  🔍 Проверяем таблицу activity...")
            if any('activity' in t[0] for t in public_tables):
                result = await session.execute(text("SELECT * FROM activity"))
                all_rows = result.fetchall()
                print(f"    Всего записей в activity: {len(all_rows)}")
                print(f"    Все записи: {all_rows}")
                
                # Проверяем запись с ID = 1
                result = await session.execute(text("SELECT * FROM activity WHERE id = 1"))
                row = result.fetchone()
                print(f"    Запись с ID = 1: {row}")
                
                if row:
                    print("  ✅ Запись activity с ID = 1 НАЙДЕНА!")
                else:
                    print("  ❌ Запись activity с ID = 1 НЕ НАЙДЕНА!")
            else:
                print("  ❌ Таблица activity НЕ НАЙДЕНА в test!")
                
                # Проверяем, есть ли другие таблицы
                if public_tables:
                    print("  📋 Найденные таблицы:")
                    for table in public_tables:
                        print(f"    - {table[0]}")
                else:
                    print("  ❌ В базе данных НЕТ ТАБЛИЦ!")
                    
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем базу данных test...")
    await check_test_db()

if __name__ == "__main__":
    asyncio.run(main())

























