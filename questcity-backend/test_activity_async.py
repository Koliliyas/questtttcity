import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, text

async def test_activity_async():
    print("🔍 Тестируем Activity через asyncpg (как в FastAPI)...")
    try:
        # Используем ТОЧНО ТАКУЮ ЖЕ конфигурацию, как в FastAPI
        engine = create_async_engine(
            'postgresql+asyncpg://postgres:postgres@localhost/questcity',
            echo=True  # Включаем SQL логи для диагностики
        )
        
        async_session = sessionmaker(
            engine, 
            class_=AsyncSession, 
            expire_on_commit=False
        )
        
        async with async_session() as session:
            print("  ✅ Сессия создана успешно")
            
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
            
            # Тест 3: session.get() (старый способ)
            print("  🔍 Тест 3: session.get()...")
            try:
                activity_get = await session.get(Activity, 1)
                print(f"    Get результат: {activity_get}")
            except Exception as e:
                print(f"    Get ошибка: {e}")
            
            # Тест 4: Проверяем все записи
            print("  🔍 Тест 4: Все записи в activity...")
            result = await session.execute(text("SELECT * FROM activity"))
            all_rows = result.fetchall()
            print(f"    Всего записей: {len(all_rows)}")
            print(f"    Первые 3: {all_rows[:3]}")
            
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def test_activity_model_async():
    print("🔍 Тестируем модель Activity в async контексте...")
    try:
        from src.db.models.quest.point import Activity
        
        print(f"  Модель: {Activity}")
        print(f"  Таблица: {Activity.__tablename__}")
        print(f"  Схема: {Activity.__table__.schema}")
        print(f"  Полное имя: {Activity.__table__.fullname}")
        print(f"  Колонки: {[c.name for c in Activity.__table__.columns]}")
        
        # Проверяем, есть ли проблемы с импортом
        print(f"  Модуль: {Activity.__module__}")
        print(f"  Класс: {Activity.__class__}")
        
    except Exception as e:
        print(f"  Ошибка модели: {e}")

async def main():
    print("🚀 Тестируем Activity через asyncpg...")
    await test_activity_model_async()
    await test_activity_async()

if __name__ == "__main__":
    asyncio.run(main())
















