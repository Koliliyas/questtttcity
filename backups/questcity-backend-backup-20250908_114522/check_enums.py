#!/usr/bin/env python3
"""
Проверка enum значений в базе данных
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def check_enums():
    """Проверяем enum значения"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔍 Проверяем enum значения")
    print(f"🔗 Подключение: {database_host}:{database_port}/{database_name}")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Проверяем enum типы
        enums = await conn.fetch("""
            SELECT t.typname, e.enumlabel
            FROM pg_type t 
            JOIN pg_enum e ON t.oid = e.enumtypid  
            JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
            WHERE n.nspname = 'public'
            ORDER BY t.typname, e.enumsortorder
        """)
        
        current_enum = None
        for enum in enums:
            if enum['typname'] != current_enum:
                current_enum = enum['typname']
                print(f"\n📋 Enum '{current_enum}':")
            print(f"  - {enum['enumlabel']}")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при проверке: {e}")

if __name__ == "__main__":
    asyncio.run(check_enums())
