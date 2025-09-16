#!/usr/bin/env python3
"""
Проверка структуры таблицы quest
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def check_quest_structure():
    """Проверяем структуру таблицы quest"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔍 Проверяем структуру таблицы quest")
    print(f"🔗 Подключение: {database_host}:{database_port}/{database_name}")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Проверяем структуру таблицы quest
        print("\n📋 Таблица 'quest':")
        quest_columns = await conn.fetch("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'quest'
            ORDER BY ordinal_position
        """)
        
        for col in quest_columns:
            print(f"  - {col['column_name']}: {col['data_type']} ({'NULL' if col['is_nullable'] == 'YES' else 'NOT NULL'})")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при проверке: {e}")

if __name__ == "__main__":
    asyncio.run(check_quest_structure())
