import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def fix_questcity_db_enum():
    print("🔧 Исправляем enum grouptype в базе questcity_db...")

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
            print(f"    📋 Текущие значения: {[row[0] for row in enum_values]}")

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

            # Проверяем, есть ли значение 'ALONE'
            final_has_alone = any('ALONE' in str(row[0]) for row in final_enum_values)
            print(f"    ✅ Есть ли 'ALONE' после исправления: {final_has_alone}")

            if final_has_alone:
                print("\n  🎉 Enum grouptype в questcity_db исправлен!")
                print("  💡 Теперь FastAPI должен работать корректно!")
            else:
                print("\n  ❌ Что-то пошло не так!")

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Исправляем enum в questcity_db...")
    await fix_questcity_db_enum()

if __name__ == "__main__":
    asyncio.run(main())











