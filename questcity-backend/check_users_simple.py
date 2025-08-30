#!/usr/bin/env python3
"""
Простой скрипт для проверки пользователей в базе данных
"""

import asyncio
import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.ext.asyncio import create_async_engine

async def check_users():
    """Проверяем пользователей в базе данных"""
    
    # Получаем переменные окружения
    database_url = os.getenv('DATABASE_URL', 'postgresql+asyncpg://postgres:postgres@localhost:5432/questcity_db')
    
    print("🔍 Проверка пользователей в базе данных")
    print(f"📊 DATABASE_URL: {database_url}")
    
    try:
        # Создаем асинхронное подключение к БД
        engine = create_async_engine(database_url, echo=False)
        
        async with engine.begin() as conn:
            print("\n📋 Проверяем таблицу пользователей...")
            
            # Проверяем таблицу user
            result = await conn.execute(text("""
                SELECT column_name, data_type, is_nullable 
                FROM information_schema.columns 
                WHERE table_name = 'user' 
                ORDER BY ordinal_position
            """))
            user_columns = result.fetchall()
            
            print("📊 Таблица 'user':")
            for col in user_columns:
                print(f"  - {col[0]}: {col[1]} ({'NULL' if col[2] == 'YES' else 'NOT NULL'})")
            
            # Проверяем количество пользователей
            result = await conn.execute(text("SELECT COUNT(*) FROM \"user\""))
            user_count = result.scalar()
            print(f"\n📊 Всего пользователей в БД: {user_count}")
            
            # Показываем всех пользователей
            result = await conn.execute(text("""
                SELECT id, username, email, is_verified, is_active, role
                FROM "user" 
                ORDER BY id
            """))
            users = result.fetchall()
            
            print(f"\n📊 Все пользователи:")
            for user in users:
                print(f"  - ID: {user[0]}, Username: '{user[1]}', Email: '{user[2]}', Verified: {user[3]}, Active: {user[4]}, Role: {user[5]}")
            
            # Проверяем админов
            result = await conn.execute(text("""
                SELECT id, username, email, role
                FROM "user" 
                WHERE role = 'admin'
                ORDER BY id
            """))
            admins = result.fetchall()
            
            print(f"\n📊 Администраторы:")
            for admin in admins:
                print(f"  - ID: {admin[0]}, Username: '{admin[1]}', Email: '{admin[2]}', Role: {admin[3]}")
        
        await engine.dispose()
        
    except Exception as e:
        print(f"❌ Ошибка при проверке БД: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(check_users())







