import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def copy_activity_data():
    print("🔍 Копируем данные activity из questcity в questcity_db...")
    
    # Подключаемся к исходной базе questcity
    source_engine = create_async_engine(
        'postgresql+asyncpg://postgres:postgres@localhost/questcity',
        echo=False
    )
    
    # Подключаемся к целевой базе questcity_db
    target_engine = create_async_engine(
        'postgresql+asyncpg://postgres:postgres@localhost/questcity_db',
        echo=False
    )
    
    source_session = sessionmaker(
        source_engine, 
        class_=AsyncSession, 
        expire_on_commit=False
    )
    
    target_session = sessionmaker(
        target_engine, 
        class_=AsyncSession, 
        expire_on_commit=False
    )
    
    try:
        # Читаем данные из исходной базы
        async with source_session() as source_sess:
            print("  🔍 Читаем данные из questcity...")
            
            # Проверяем структуру таблицы
            result = await source_sess.execute(text("""
                SELECT column_name, data_type, is_nullable 
                FROM information_schema.columns 
                WHERE table_name = 'activity' 
                ORDER BY ordinal_position
            """))
            columns = result.fetchall()
            print(f"    Структура таблицы: {columns}")
            
            # Читаем все записи
            result = await source_sess.execute(text("SELECT * FROM activity"))
            all_rows = result.fetchall()
            print(f"    Всего записей для копирования: {len(all_rows)}")
            print(f"    Записи: {all_rows}")
            
            if not all_rows:
                print("  ❌ В исходной базе нет данных для копирования!")
                return
            
            # Копируем данные в целевую базу
            async with target_session() as target_sess:
                print("  🔍 Копируем данные в questcity_db...")
                
                # Проверяем, есть ли таблица в целевой базе
                result = await target_sess.execute(text("""
                    SELECT COUNT(*) FROM information_schema.tables 
                    WHERE table_name = 'activity' AND table_schema = 'public'
                """))
                table_exists = result.scalar()
                
                if not table_exists:
                    print("  ❌ Таблица activity не существует в questcity_db!")
                    return
                
                # Очищаем существующие данные
                print("  🗑️ Очищаем существующие данные...")
                await target_sess.execute(text("DELETE FROM activity"))
                
                # Копируем данные
                print("  📋 Копируем данные...")
                for row in all_rows:
                    # Формируем INSERT запрос с конкретными значениями
                    insert_sql = f"INSERT INTO activity (id, name) VALUES ({row[0]}, '{row[1]}')"
                    await target_sess.execute(text(insert_sql))
                
                # Коммитим изменения
                await target_sess.commit()
                print("  ✅ Данные скопированы успешно!")
                
                # Проверяем результат
                result = await target_sess.execute(text("SELECT * FROM activity"))
                copied_rows = result.fetchall()
                print(f"    Всего записей после копирования: {len(copied_rows)}")
                print(f"    Скопированные записи: {copied_rows}")
                
                # Проверяем конкретную запись с ID = 1
                result = await target_sess.execute(text("SELECT * FROM activity WHERE id = 1"))
                row_1 = result.fetchone()
                print(f"    Запись с ID = 1: {row_1}")
                
                if row_1:
                    print("  ✅ Запись activity с ID = 1 успешно скопирована!")
                else:
                    print("  ❌ Запись activity с ID = 1 НЕ скопирована!")
                    
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Копируем данные activity...")
    await copy_activity_data()

if __name__ == "__main__":
    asyncio.run(main())
