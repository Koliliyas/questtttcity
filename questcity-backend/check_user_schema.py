#!/usr/bin/env python3
"""
Скрипт для проверки схемы таблицы user
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def check_user_schema():
    """Проверяем схему таблицы user"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔍 Проверяем схему таблицы user")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Получаем информацию о колонках таблицы user
        columns_query = """
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_name = 'user' AND table_schema = 'public'
        ORDER BY ordinal_position
        """
        
        columns = await conn.fetch(columns_query)
        
        print(f"📊 Колонки таблицы user:")
        for column in columns:
            print(f"  - {column['column_name']}: {column['data_type']} (nullable: {column['is_nullable']})")
        
        # Проверяем существующих пользователей
        users_query = """
        SELECT id, username, email, role, is_verified, can_edit_quests, can_lock_users
        FROM "user"
        LIMIT 5
        """
        
        users = await conn.fetch(users_query)
        
        print(f"\n📊 Существующие пользователи (первые 5):")
        for user in users:
            print(f"  - {user['username']} ({user['email']}) - Role: {user['role']}")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при проверке схемы: {e}")

if __name__ == "__main__":
    asyncio.run(check_user_schema())
