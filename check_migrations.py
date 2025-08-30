import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_migrations():
    print("🔍 Проверяем статус миграций в базе данных...")

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
            print("  🔍 Проверяем таблицу alembic_version...")

            # Проверяем таблицу alembic_version
            result = await sess.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_name = 'alembic_version'
            """))
            
            alembic_table = result.fetchone()
            if alembic_table:
                print("    ✅ Таблица alembic_version существует")
                
                # Проверяем текущую версию
                result = await sess.execute(text("SELECT version_num FROM alembic_version"))
                current_version = result.fetchone()
                print(f"    📋 Текущая версия миграции: {current_version[0] if current_version else 'НЕТ'}")
            else:
                print("    ❌ Таблица alembic_version НЕ существует")
                print("    💡 Миграции не применялись!")

            print("\n  🔍 Проверяем структуру поля 'group' в таблице quest...")

            # Проверяем структуру поля group
            result = await sess.execute(text("""
                SELECT column_name, data_type, udt_name, is_nullable
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

            print("\n  🔍 Проверяем enum grouptype...")

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
                
                if not enum_values:
                    print("    ❌ Enum grouptype не содержит значений!")
                else:
                    print("    ✅ Enum grouptype содержит значения")
            else:
                print("    ❌ Enum grouptype НЕ существует")

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем миграции...")
    await check_migrations()

if __name__ == "__main__":
    asyncio.run(main())

















