import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text, select
from src.db.models.quest.point import Activity

async def debug_activity_query():
    print("🔍 Детальная диагностика запроса activity...")
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
            
            # Проверяем текущую схему
            print("  🔍 Проверяем текущую схему...")
            result = await session.execute(text("SELECT current_schema()"))
            schema = result.scalar()
            print(f"    Текущая схема: {schema}")
            
            # Проверяем все схемы
            print("  🔍 Проверяем все схемы...")
            result = await session.execute(text("SELECT schema_name FROM information_schema.schemata"))
            schemas = result.fetchall()
            print(f"    Все схемы: {[s[0] for s in schemas]}")
            
            # Проверяем таблицу activity в текущей схеме
            print("  🔍 Проверяем таблицу activity в текущей схеме...")
            result = await session.execute(text("""
                SELECT table_name, table_schema 
                FROM information_schema.tables 
                WHERE table_name = 'activity'
            """))
            table_info = result.fetchone()
            print(f"    Информация о таблице: {table_info}")
            
            # Проверяем таблицу activity в схеме public
            print("  🔍 Проверяем таблицу activity в схеме public...")
            result = await session.execute(text("""
                SELECT table_name, table_schema 
                FROM information_schema.tables 
                WHERE table_name = 'activity' AND table_schema = 'public'
            """))
            public_table_info = result.fetchone()
            print(f"    Таблица в public: {public_table_info}")
            
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
            
            # Проверяем запись activity через прямой SQL в схеме public
            print("  🔍 Проверяем запись activity в схеме public...")
            result = await session.execute(text("SELECT * FROM public.activity WHERE id = 1"))
            public_row = result.fetchone()
            print(f"    Запись в public.activity: {public_row}")
            
            # Проверяем запись activity через SQLAlchemy
            print("  🔍 Проверяем запись activity через SQLAlchemy...")
            stmt = select(Activity).where(Activity.id == 1)
            result = await session.execute(stmt)
            activity = result.scalar_one_or_none()
            print(f"    SQLAlchemy результат: {activity}")
            
            # Проверяем __tablename__ модели
            print("  🔍 Проверяем __tablename__ модели Activity...")
            print(f"    __tablename__: {Activity.__tablename__}")
            print(f"    __table__.schema: {Activity.__table__.schema}")
            
            # Проверяем через session.get()
            print("  🔍 Проверяем через session.get()...")
            try:
                activity_get = await session.get(Activity, 1)
                print(f"    session.get() результат: {activity_get}")
            except Exception as e:
                print(f"    session.get() ошибка: {e}")
            
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Детальная диагностика запроса activity...")
    await debug_activity_query()

if __name__ == "__main__":
    asyncio.run(main())

























