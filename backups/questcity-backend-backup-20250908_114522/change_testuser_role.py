#!/usr/bin/env python3
"""
Скрипт для изменения роли testuser@questcity.com с админа на обычного пользователя
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def change_testuser_role():
    """Изменяем роль testuser на обычного пользователя"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔧 Изменяем роль testuser@questcity.com")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Проверяем текущие данные пользователя
        current_user = await conn.fetchrow("""
            SELECT id, username, email, role, is_verified, can_edit_quests, can_lock_users 
            FROM "user" 
            WHERE email = 'testuser@questcity.com'
        """)
        
        if not current_user:
            print("❌ Пользователь testuser@questcity.com не найден")
            return
        
        print(f"📊 Текущие данные пользователя:")
        print(f"  - ID: {current_user['id']}")
        print(f"  - Username: {current_user['username']}")
        print(f"  - Email: {current_user['email']}")
        print(f"  - Role: {current_user['role']} (0=USER, 1=MODERATOR, 2=ADMIN)")
        print(f"  - is_verified: {current_user['is_verified']}")
        print(f"  - can_edit_quests: {current_user['can_edit_quests']}")
        print(f"  - can_lock_users: {current_user['can_lock_users']}")
        
        # Обновляем роль на обычного пользователя
        update_result = await conn.execute("""
            UPDATE "user" 
            SET role = 0, can_edit_quests = false, can_lock_users = false
            WHERE email = 'testuser@questcity.com'
        """)
        
        if update_result == "UPDATE 1":
            print(f"\n✅ Роль пользователя успешно изменена!")
        else:
            print(f"\n❌ Ошибка при обновлении роли")
            return
        
        # Проверяем обновленные данные
        updated_user = await conn.fetchrow("""
            SELECT id, username, email, role, is_verified, can_edit_quests, can_lock_users 
            FROM "user" 
            WHERE email = 'testuser@questcity.com'
        """)
        
        if updated_user:
            print(f"\n📊 Обновленные данные пользователя:")
            print(f"  - ID: {updated_user['id']}")
            print(f"  - Username: {updated_user['username']}")
            print(f"  - Email: {updated_user['email']}")
            print(f"  - Role: {updated_user['role']} (0=USER, 1=MODERATOR, 2=ADMIN)")
            print(f"  - is_verified: {updated_user['is_verified']}")
            print(f"  - can_edit_quests: {updated_user['can_edit_quests']}")
            print(f"  - can_lock_users: {updated_user['can_lock_users']}")
            
            print(f"\n🔐 Данные для входа за обычного пользователя:")
            print(f"  - Email: testuser@questcity.com")
            print(f"  - Password: testuser123 (предполагаемый пароль)")
            print(f"  - Роль: USER (обычный пользователь)")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при изменении роли: {e}")

if __name__ == "__main__":
    asyncio.run(change_testuser_role())
