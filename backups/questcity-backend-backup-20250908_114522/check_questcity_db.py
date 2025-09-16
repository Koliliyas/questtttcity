import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_questcity_db():
    print("🔍 Проверяем базу данных questcity_db...")

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
            print("  🔍 Проверяем enum grouptype в questcity_db...")

            # Проверяем enum grouptype
            result = await sess.execute(text("""
                SELECT typname, typtype
                FROM pg_type
                WHERE typname = 'grouptype'
            """))
            
            enum_type = result.fetchone()
            if enum_type:
                print(f"    ✅ Enum grouptype существует: {enum_type}")
                
                # Проверяем значения enum
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
                print(f"    📋 Значения enum: {[row[0] for row in enum_values]}")
            else:
                print("    ❌ Enum grouptype НЕ существует в questcity_db")

            print("\n  🔍 Проверяем структуру поля 'group' в таблице quest...")

            # Проверяем структуру поля group
            result = await sess.execute(text("""
                SELECT column_name, data_type, udt_name
                FROM information_schema.columns
                WHERE table_name = 'quest' AND column_name = 'group'
            """))
            
            column_info = result.fetchone()
            if column_info:
                print(f"    📋 Поле 'group': {column_info}")
                
                if column_info[1] == 'USER-DEFINED':
                    print("    ✅ Поле имеет пользовательский тип (enum)")
                else:
                    print(f"    ❌ Поле имеет тип {column_info[1]}, ожидается enum")
            else:
                print("    ❌ Поле 'group' не найдено в таблице quest")

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем questcity_db...")
    await check_questcity_db()

if __name__ == "__main__":
    asyncio.run(main())
