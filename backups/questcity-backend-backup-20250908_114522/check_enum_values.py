import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_enum_values():
    print("🔍 Проверяем значения enum в обеих базах данных...")

    # База questcity
    print("\n📋 БАЗА questcity:")
    engine_questcity = create_async_engine(
        'postgresql+asyncpg://postgres:postgres@localhost/questcity',
        echo=False
    )

    session_questcity = sessionmaker(
        engine_questcity,
        class_=AsyncSession,
        expire_on_commit=False
    )

    try:
        async with session_questcity() as sess:
            # Проверяем значения enum grouptype
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
            
            # Проверяем, есть ли 'ALONE'
            has_alone = any('ALONE' in str(row[0]) for row in enum_values)
            print(f"    ✅ Есть ли 'ALONE': {has_alone}")

    except Exception as e:
        print(f"    ❌ Ошибка: {e}")

    # База questcity_db
    print("\n📋 БАЗА questcity_db:")
    engine_questcity_db = create_async_engine(
        'postgresql+asyncpg://postgres:postgres@localhost/questcity_db',
        echo=False
    )

    session_questcity_db = sessionmaker(
        engine_questcity_db,
        class_=AsyncSession,
        expire_on_commit=False
    )

    try:
        async with session_questcity_db() as sess:
            # Проверяем значения enum grouptype
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
            
            # Проверяем, есть ли 'ALONE'
            has_alone = any('ALONE' in str(row[0]) for row in enum_values)
            print(f"    ✅ Есть ли 'ALONE': {has_alone}")

    except Exception as e:
        print(f"    ❌ Ошибка: {e}")

    print("\n🔍 Проверяем, к какой базе подключается FastAPI...")
    print("💡 Проверьте .env файл - DATABASE_NAME должен быть questcity_db")

async def main():
    print("🚀 Проверяем enum значения...")
    await check_enum_values()

if __name__ == "__main__":
    asyncio.run(main())

























