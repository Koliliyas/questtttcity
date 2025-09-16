#!/usr/bin/env python3
"""
Простой скрипт для изменения роли пользователя
"""
import asyncio
import asyncpg
import os
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

async def update_user_role():
    """Обновляет роль пользователя на ADMIN"""
    
    # Параметры подключения к базе данных
    db_config = {
        'host': 'localhost',
        'port': 5432,
        'user': os.getenv('DATABASE_USERNAME', 'postgres'),
        'password': os.getenv('DATABASE_PASSWORD', 'postgres'),
        'database': os.getenv('DATABASE_NAME', 'questcity'),
    }
    
    print("🔧 Подключение к базе данных...")
    print(f"   Host: {db_config['host']}:{db_config['port']}")
    print(f"   Database: {db_config['database']}")
    print(f"   User: {db_config['user']}")
    
    try:
        # Подключаемся к базе данных
        conn = await asyncpg.connect(**db_config)
        print("✅ Подключение к базе данных установлено")
        
        # Обновляем роль пользователя
        email = 'testuser@questcity.com'
        print(f"🔄 Обновление роли пользователя {email} на ADMIN...")
        
        result = await conn.execute("""
            UPDATE "user" 
            SET role = 2, is_verified = true
            WHERE email = $1
        """, email)
        
        if result == "UPDATE 1":
            print("✅ Роль пользователя успешно обновлена на ADMIN")
            print("✅ Пользователь верифицирован")
        else:
            print("⚠️  Пользователь не найден или роль уже установлена")
        
        # Даем права на просмотр квестов
        print("🔄 Обновление разрешений пользователя...")
        
        await conn.execute("""
            UPDATE "user" 
            SET can_edit_quests = true
            WHERE email = $1
        """, email)
        
        print("✅ Разрешения на редактирование квестов предоставлены")
        
        # Проверяем результат
        user = await conn.fetchrow("""
            SELECT username, email, role, is_active, is_verified, can_edit_quests
            FROM "user" 
            WHERE email = $1
        """, email)
        
        if user:
            print("📋 Информация о пользователе:")
            print(f"   Username: {user['username']}")
            print(f"   Email: {user['email']}")
            print(f"   Role: {user['role']} (0=User, 1=Moderator, 2=Admin)")
            print(f"   Active: {user['is_active']}")
            print(f"   Verified: {user['is_verified']}")
            print(f"   Can Edit Quests: {user['can_edit_quests']}")
        else:
            print("❌ Пользователь не найден")
        
        await conn.close()
        print("✅ Соединение с базой данных закрыто")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(update_user_role())
