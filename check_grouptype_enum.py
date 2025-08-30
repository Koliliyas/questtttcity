import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_grouptype_enum():
    print("🔍 Проверяем enum grouptype в базе данных...")

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
            print("  🔍 Проверяем текущие значения enum grouptype...")

            # Проверяем текущие значения enum
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
            print(f"    Текущие значения enum grouptype: {[row[0] for row in enum_values]}")

            # Проверяем структуру таблицы quest
            result = await sess.execute(text("""
                SELECT column_name, data_type, udt_name
                FROM information_schema.columns
                WHERE table_name = 'quest' AND column_name = 'group'
            """))
            
            column_info = result.fetchone()
            print(f"    Структура поля 'group': {column_info}")

            # Проверяем, есть ли значение 'ALONE' в enum
            if enum_values:
                has_alone = any('ALONE' in str(row[0]) for row in enum_values)
                print(f"    Есть ли 'ALONE' в enum: {has_alone}")

                if not has_alone:
                    print("  ❌ Значение 'ALONE' отсутствует в enum grouptype!")
                    print("  💡 Нужно добавить 'ALONE' в enum")
                else:
                    print("  ✅ Значение 'ALONE' присутствует в enum grouptype")

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем enum grouptype...")
    await check_grouptype_enum()

if __name__ == "__main__":
    asyncio.run(main())

















