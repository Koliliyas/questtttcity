import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def fix_database_schema():
    print("🔧 Исправляем структуру базы данных...")

    # Подключаемся к базе questcity
    engine = create_async_engine(
        'postgresql+asyncpg://postgres:postgres@localhost/questcity',
        echo=False
    )

    session = sessionmaker(
        engine,
        class_=AsyncSession,
        expire_on_commit=False
    )

    try:
        async with session() as sess:
            print("  🔍 Проверяем текущее состояние...")

            # Проверяем, существует ли enum grouptype
            result = await sess.execute(text("""
                SELECT typname, typtype
                FROM pg_type
                WHERE typname = 'grouptype'
            """))
            
            enum_exists = result.fetchone()
            
            if not enum_exists:
                print("  🔧 Создаем enum grouptype...")
                
                # Создаем enum grouptype
                await sess.execute(text("""
                    CREATE TYPE grouptype AS ENUM ('ALONE', 'TWO', 'THREE', 'FOUR')
                """))
                print("    ✅ Enum grouptype создан")
            else:
                print("    ✅ Enum grouptype уже существует")

            # Проверяем структуру поля group в таблице quest
            result = await sess.execute(text("""
                SELECT column_name, data_type, udt_name
                FROM information_schema.columns
                WHERE table_name = 'quest' AND column_name = 'group'
            """))
            
            column_info = result.fetchone()
            
            if column_info and column_info[1] != 'USER-DEFINED':
                print("  🔧 Изменяем тип поля 'group' на enum...")
                
                # Изменяем тип поля group на enum grouptype
                await sess.execute(text("""
                    ALTER TABLE quest 
                    ALTER COLUMN "group" TYPE grouptype 
                    USING "group"::grouptype
                """))
                print("    ✅ Тип поля 'group' изменен на enum")
            else:
                print("    ✅ Поле 'group' уже имеет правильный тип")

            # Проверяем, есть ли значения в enum
            result = await sess.execute(text("""
                SELECT enumlabel 
                FROM pg_enum 
                WHERE enumtypid = (
                    SELECT oid 
                    FROM pg_type 
                    WHERE typname = 'grouptype'
                )
                ORDER BY enumsortorder
            """))
            
            enum_values = result.fetchall()
            print(f"    📋 Значения enum grouptype: {[row[0] for row in enum_values]}")

            # Проверяем, есть ли значение 'ALONE'
            has_alone = any('ALONE' in str(row[0]) for row in enum_values)
            
            if not has_alone:
                print("  🔧 Добавляем значение 'ALONE' в enum...")
                
                # Добавляем значение 'ALONE' в enum
                await sess.execute(text("""
                    ALTER TYPE grouptype ADD VALUE 'ALONE'
                """))
                print("    ✅ Значение 'ALONE' добавлено в enum")
            else:
                print("    ✅ Значение 'ALONE' уже есть в enum")

            # Коммитим изменения
            await sess.commit()
            print("  ✅ Изменения сохранены в базе данных")

            print("\n  🔍 Проверяем результат...")

            # Проверяем финальное состояние
            result = await sess.execute(text("""
                SELECT column_name, data_type, udt_name
                FROM information_schema.columns
                WHERE table_name = 'quest' AND column_name = 'group'
            """))
            
            final_column_info = result.fetchone()
            print(f"    📋 Финальное состояние поля 'group': {final_column_info}")

            result = await sess.execute(text("""
                SELECT enumlabel 
                FROM pg_enum 
                WHERE enumtypid = (
                    SELECT oid 
                    FROM pg_type 
                    WHERE typname = 'grouptype'
                )
                ORDER BY enumsortorder
            """))
            
            final_enum_values = result.fetchall()
            print(f"    📋 Финальные значения enum: {[row[0] for row in final_enum_values]}")

            print("\n  🎉 Структура базы данных исправлена!")

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Исправляем структуру базы данных...")
    await fix_database_schema()

if __name__ == "__main__":
    asyncio.run(main())











