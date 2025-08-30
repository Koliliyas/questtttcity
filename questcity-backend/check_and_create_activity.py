import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_and_create_activity():
    print("🔍 Проверяем и создаем запись activity...")
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
            
            # Проверяем все записи в таблице activity
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
            
            # Если записи нет, создаем её
            if row is None:
                print("  ⚠️ Запись с ID = 1 не найдена, создаем...")
                
                # Проверяем структуру таблицы
                result = await session.execute(text("""
                    SELECT column_name, data_type, is_nullable 
                    FROM information_schema.columns 
                    WHERE table_name = 'activity' 
                    ORDER BY ordinal_position
                """))
                columns = result.fetchall()
                print(f"    Структура таблицы: {columns}")
                
                # Создаем запись activity
                try:
                    await session.execute(text("""
                        INSERT INTO activity (id, name) 
                        VALUES (1, 'activity')
                    """))
                    await session.commit()
                    print("  ✅ Запись activity с ID = 1 создана успешно!")
                    
                    # Проверяем, что запись создалась
                    result = await session.execute(text("SELECT * FROM activity WHERE id = 1"))
                    new_row = result.fetchone()
                    print(f"    Новая запись: {new_row}")
                    
                except Exception as e:
                    print(f"  ❌ Ошибка создания записи: {e}")
                    await session.rollback()
            else:
                print("  ✅ Запись с ID = 1 уже существует")
            
            # Проверяем все записи после изменений
            print("  🔍 Проверяем все записи после изменений...")
            result = await session.execute(text("SELECT * FROM activity"))
            all_rows = result.fetchall()
            print(f"    Всего записей: {len(all_rows)}")
            print(f"    Все записи: {all_rows}")
            
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем и создаем запись activity...")
    await check_and_create_activity()

if __name__ == "__main__":
    asyncio.run(main())
















