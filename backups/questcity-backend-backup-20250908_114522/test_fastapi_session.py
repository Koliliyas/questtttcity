import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, text

async def test_fastapi_session():
    print("🔍 Тестируем сессию как в FastAPI...")
    try:
        # Используем ТОЧНО ТАКУЮ ЖЕ конфигурацию, как в FastAPI
        engine = create_async_engine(
            'postgresql+asyncpg://postgres:postgres@localhost:5432/questcity',
            echo=True,
            pool_size=20,
            max_overflow=30,
            pool_timeout=30,
            pool_recycle=3600,
            pool_pre_ping=True,
            connect_args={
                "command_timeout": 60,
                "server_settings": {
                    "application_name": "questcity_backend",
                },
            }
        )
        
        async_session_factory = async_sessionmaker(
            bind=engine,
            expire_on_commit=False
        )
        
        print("  ✅ Engine и session_factory созданы")
        
        # Имитируем создание сессии как в FastAPI
        async with async_session_factory() as session:
            print("  ✅ Сессия создана через session_factory")
            
            # Тест 1: Прямой SQL запрос
            print("  🔍 Тест 1: Прямой SQL запрос...")
            result = await session.execute(text("SELECT * FROM activity WHERE id = 1"))
            row = result.fetchone()
            print(f"    SQL результат: {row}")
            
            # Тест 2: SQLAlchemy select
            print("  🔍 Тест 2: SQLAlchemy select...")
            from src.db.models.quest.point import Activity
            stmt = select(Activity).where(Activity.id == 1)
            result = await session.execute(stmt)
            activity = result.scalar_one_or_none()
            print(f"    Select результат: {activity}")
            
            # Тест 3: session.get() (как в TypeRepository)
            print("  🔍 Тест 3: session.get()...")
            try:
                activity_get = await session.get(Activity, 1)
                print(f"    Get результат: {activity_get}")
            except Exception as e:
                print(f"    Get ошибка: {e}")
            
            # Тест 4: Проверяем состояние сессии
            print("  🔍 Тест 4: Состояние сессии...")
            print(f"    Сессия активна: {session.is_active}")
            print(f"    Сессия в транзакции: {session.in_transaction()}")
            
            # Тест 5: Проверяем все записи
            print("  🔍 Тест 5: Все записи в activity...")
            result = await session.execute(text("SELECT COUNT(*) FROM activity"))
            count = result.scalar()
            print(f"    Всего записей: {count}")
            
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Тестируем сессию как в FastAPI...")
    await test_fastapi_session()

if __name__ == "__main__":
    asyncio.run(main())
