import asyncio
import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

async def check_fastapi_config():
    print("🔍 Проверяем конфигурацию FastAPI...")
    
    # Показываем все переменные окружения, связанные с базой данных
    print("  📋 Переменные окружения:")
    for key, value in os.environ.items():
        if 'database' in key.lower() or 'db' in key.lower() or 'postgres' in key.lower():
            print(f"    {key}: {value}")
    
    # Проверяем настройки по умолчанию
    print("  📋 Настройки по умолчанию:")
    print(f"    DATABASE_DRIVER: {os.getenv('DATABASE_DRIVER', 'postgresql+asyncpg')}")
    print(f"    DATABASE_USERNAME: {os.getenv('DATABASE_USERNAME', 'postgres')}")
    print(f"    DATABASE_PASSWORD: {os.getenv('DATABASE_PASSWORD', 'postgres')}")
    print(f"    DATABASE_HOST: {os.getenv('DATABASE_HOST', 'localhost')}")
    print(f"    DATABASE_PORT: {os.getenv('DATABASE_PORT', '5432')}")
    print(f"    DATABASE_NAME: {os.getenv('DATABASE_NAME', 'questcity')}")
    
    # Формируем URL для подключения
    driver = os.getenv('DATABASE_DRIVER', 'postgresql+asyncpg')
    username = os.getenv('DATABASE_USERNAME', 'postgres')
    password = os.getenv('DATABASE_PASSWORD', 'postgres')
    host = os.getenv('DATABASE_HOST', 'localhost')
    port = os.getenv('DATABASE_PORT', '5432')
    name = os.getenv('DATABASE_NAME', 'questcity')
    
    url = f"{driver}://{username}:{password}@{host}:{port}/{name}"
    print(f"  🔗 URL подключения: {url}")
    
    # Тестируем подключение с этими параметрами
    print("  🔍 Тестируем подключение...")
    try:
        engine = create_async_engine(url, echo=True)
        
        async_session = sessionmaker(
            engine, 
            class_=AsyncSession, 
            expire_on_commit=False
        )
        
        async with async_session() as session:
            print("    ✅ Сессия создана успешно")
            
            # Проверяем текущую схему
            print("    🔍 Проверяем текущую схему...")
            result = await session.execute(text("SELECT current_schema()"))
            schema = result.scalar()
            print(f"      Текущая схема: {schema}")
            
            # Проверяем таблицу activity
            print("    🔍 Проверяем таблицу activity...")
            result = await session.execute(text("SELECT * FROM activity WHERE id = 1"))
            row = result.fetchone()
            print(f"      Запись с ID = 1: {row}")
            
            # Проверяем все таблицы в текущей схеме
            print("    🔍 Проверяем все таблицы в текущей схеме...")
            result = await session.execute(text("""
                SELECT table_name, table_schema 
                FROM information_schema.tables 
                WHERE table_schema = current_schema()
                ORDER BY table_name
            """))
            tables = result.fetchall()
            print(f"      Таблицы в схеме {schema}: {[t[0] for t in tables]}")
            
    except Exception as e:
        print(f"    ❌ Ошибка подключения: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("🚀 Проверяем конфигурацию FastAPI...")
    await check_fastapi_config()

if __name__ == "__main__":
    asyncio.run(main())
















