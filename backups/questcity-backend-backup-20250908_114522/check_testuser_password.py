#!/usr/bin/env python3
"""
Скрипт для проверки и установки пароля для testuser@questcity.com
"""

import asyncio
import asyncpg
import os
import sys
from dotenv import load_dotenv
import bcrypt

# Добавляем путь к модулям проекта
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from src.core.authentication.utils import hash_password, validate_password

load_dotenv()

async def check_and_set_testuser_password():
    """Проверяем и устанавливаем пароль для testuser"""
    
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔐 Проверяем пароль для testuser@questcity.com")
    print("=" * 60)
    
    try:
        conn = await asyncpg.connect(database_url)
        
        # Получаем текущий хеш пароля
        user_data = await conn.fetchrow("""
            SELECT id, username, email, password
            FROM "user" 
            WHERE email = 'testuser@questcity.com'
        """)
        
        if not user_data:
            print("❌ Пользователь testuser@questcity.com не найден")
            return
        
        print(f"📊 Пользователь найден:")
        print(f"  - Username: {user_data['username']}")
        print(f"  - Email: {user_data['email']}")
        print(f"  - Password hash: {user_data['password'][:50]}...")
        
        # Список возможных паролей для проверки
        possible_passwords = [
            "testuser123",
            "password123", 
            "testuser",
            "123456",
            "admin123"
        ]
        
        current_hash = user_data['password']
        found_password = None
        
        print(f"\n🔍 Проверяем возможные пароли...")
        for password in possible_passwords:
            try:
                if validate_password(password, current_hash):
                    found_password = password
                    print(f"✅ Найден правильный пароль: {password}")
                    break
                else:
                    print(f"❌ Неверный пароль: {password}")
            except Exception as e:
                print(f"❌ Ошибка при проверке пароля '{password}': {e}")
        
        if not found_password:
            print(f"\n🔧 Устанавливаем новый пароль: password123")
            
            # Создаем новый хеш пароля
            new_password = "password123"
            new_hash = hash_password(new_password).decode('utf-8')
            
            # Обновляем пароль в базе
            await conn.execute("""
                UPDATE "user" 
                SET password = $1
                WHERE email = 'testuser@questcity.com'
            """, new_hash)
            
            print(f"✅ Пароль успешно обновлен!")
            found_password = new_password
        
        print(f"\n🔐 Данные для входа за обычного пользователя:")
        print(f"  - Email: testuser@questcity.com")
        print(f"  - Password: {found_password}")
        print(f"  - Роль: USER (обычный пользователь)")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    asyncio.run(check_and_set_testuser_password())
