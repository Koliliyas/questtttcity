#!/usr/bin/env python3
"""
Скрипт для сброса пароля админа
"""

import asyncio
import asyncpg
import os
import bcrypt
from dotenv import load_dotenv

load_dotenv()

async def reset_admin_password():
    """Сбрасываем пароль админа"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print("🔐 Сбрасываем пароль админа...")
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Новый пароль
        new_password = "Admin123!"
        password_hash = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        
        # Обновляем пароль админа
        update_query = """
        UPDATE "user" 
        SET password = $1 
        WHERE email = 'admin@questcity.com'
        RETURNING id, username, email
        """
        
        result = await conn.fetchrow(update_query, password_hash)
        
        if result:
            print(f"✅ Пароль админа обновлен!")
            print(f"   ID: {result['id']}")
            print(f"   Username: {result['username']}")
            print(f"   Email: {result['email']}")
            print(f"   Новый пароль: {new_password}")
        else:
            print("❌ Админ не найден")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при сбросе пароля: {e}")

if __name__ == "__main__":
    asyncio.run(reset_admin_password())
