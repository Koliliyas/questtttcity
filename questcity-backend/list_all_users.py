#!/usr/bin/env python3
"""
Скрипт для вывода всех пользователей с их ролями
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def list_all_users():
    """Выводим всех пользователей с их ролями"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"📊 Все пользователи в системе")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Получаем всех пользователей
        users_query = """
        SELECT id, username, email, role, is_verified, is_active, can_edit_quests, can_lock_users
        FROM "user"
        ORDER BY username
        """
        
        users = await conn.fetch(users_query)
        
        role_names = {0: "USER", 1: "MODERATOR", 2: "ADMIN"}
        
        print(f"📊 Всего пользователей: {len(users)}")
        print()
        
        for user in users:
            role_name = role_names.get(user['role'], f"UNKNOWN({user['role']})")
            status = "✅ Активен" if user['is_active'] else "❌ Неактивен"
            verified = "✅ Верифицирован" if user['is_verified'] else "❌ Не верифицирован"
            
            print(f"👤 {user['username']} ({user['email']})")
            print(f"   - ID: {user['id']}")
            print(f"   - Роль: {role_name}")
            print(f"   - Статус: {status}")
            print(f"   - Верификация: {verified}")
            print(f"   - Может редактировать квесты: {'Да' if user['can_edit_quests'] else 'Нет'}")
            print(f"   - Может блокировать пользователей: {'Да' if user['can_lock_users'] else 'Нет'}")
            print()
        
        # Показываем обычных пользователей (role = 0)
        regular_users = [u for u in users if u['role'] == 0]
        if regular_users:
            print(f"🔐 Обычные пользователи (role = 0):")
            for user in regular_users:
                print(f"   - {user['username']} ({user['email']})")
        else:
            print("❌ Обычных пользователей (role = 0) не найдено")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при получении пользователей: {e}")

if __name__ == "__main__":
    asyncio.run(list_all_users())
