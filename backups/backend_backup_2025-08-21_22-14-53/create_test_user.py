#!/usr/bin/env python3
"""
Скрипт для создания тестового обычного пользователя
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv
import hashlib

load_dotenv()

async def create_test_user():
    """Создаем тестового обычного пользователя"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🧪 Создаем тестового обычного пользователя")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Проверяем, есть ли уже тестовый пользователь
        existing_user = await conn.fetchrow("""
            SELECT id, username, email, role, is_verified 
            FROM "user" 
            WHERE email = 'test@questcity.com'
        """)
        
        if existing_user:
            print(f"📊 Тестовый пользователь уже существует:")
            print(f"  - ID: {existing_user['id']}")
            print(f"  - Username: {existing_user['username']}")
            print(f"  - Email: {existing_user['email']}")
            print(f"  - Role: {existing_user['role']} (0=USER, 1=MODERATOR, 2=ADMIN)")
            print(f"  - is_verified: {existing_user['is_verified']}")
            print(f"\n🔐 Данные для входа:")
            print(f"  - Email: test@questcity.com")
            print(f"  - Password: password123")
            return
        
        # Находим свободный profile_id
        max_profile_id = await conn.fetchval("SELECT COALESCE(MAX(profile_id), 0) FROM \"user\"")
        new_profile_id = max_profile_id + 1
        
        # Создаем хеш пароля (password123)
        password_hash = hashlib.sha256("password123".encode()).hexdigest()
        
        # Создаем тестового пользователя
        user_query = """
        INSERT INTO "user" (id, username, first_name, last_name, password, email, profile_id, role, is_active, is_verified, created_at, updated_at, can_edit_quests, can_lock_users)
        VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW(), $10, $11)
        RETURNING id, username, email, role, is_verified
        """
        
        user_result = await conn.fetchrow(
            user_query,
            "testuser",
            "Test",
            "User",
            password_hash,
            "test@questcity.com",
            new_profile_id,  # profile_id
            0,  # USER role
            True,  # is_active
            True,  # is_verified
            False,  # can_edit_quests
            False   # can_lock_users
        )
        
        if user_result:
            print(f"✅ Тестовый пользователь создан:")
            print(f"  - ID: {user_result['id']}")
            print(f"  - Username: {user_result['username']}")
            print(f"  - Email: {user_result['email']}")
            print(f"  - Role: {user_result['role']} (0=USER, 1=MODERATOR, 2=ADMIN)")
            print(f"  - is_verified: {user_result['is_verified']}")
            print(f"\n🔐 Данные для входа:")
            print(f"  - Email: test@questcity.com")
            print(f"  - Password: password123")
        else:
            print("❌ Ошибка при создании пользователя")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при создании тестового пользователя: {e}")

if __name__ == "__main__":
    asyncio.run(create_test_user())
