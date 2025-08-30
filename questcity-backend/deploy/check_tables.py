#!/usr/bin/env python3
import asyncio
import asyncpg

async def check_tables():
    try:
        conn = await asyncpg.connect(
            host='7da2c0adf39345ca39269f40.twc1.net',
            port=5432,
            user='gen_user',
            password='|dls1z:N7#v>vr',
            database='default_db',
            ssl='require'
        )
        
        tables = await conn.fetch("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename")
        
        print("📋 Таблицы в базе данных:")
        for table in tables:
            print(f"  - {table['tablename']}")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    asyncio.run(check_tables())



