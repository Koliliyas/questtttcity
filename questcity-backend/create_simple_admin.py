#!/usr/bin/env python3
"""
Простой скрипт для создания администратора
"""
import asyncio
import sys
from pathlib import Path

# Добавляем src в путь
sys.path.insert(0, str(Path(__file__).parent / "src"))

import dotenv
from sqlalchemy import select

from core.authentication.utils import hash_password
from db.engine import async_session_factory
from db.models.user import Profile, User

# Загружаем переменные окружения
dotenv.load_dotenv()

async def create_simple_admin():
    """Создает простого администратора"""
    
    async with async_session_factory() as session:
        # Проверяем, есть ли уже администратор
        result = await session.execute(
            select(User).where(User.email == "admin@questcity.com")
        )
        existing_admin = result.scalar_one_or_none()
        
        if existing_admin:
            print("✅ Администратор уже существует!")
            return existing_admin
        
        # Создаем профиль
        profile = Profile(
            credits=10000,
            bio="System Administrator",
            avatar_url="",
            instagram_username="",
            telegram_username=""
        )
        session.add(profile)
        await session.flush()  # Получаем ID профиля
        
        # Создаем пользователя
        admin = User(
            username="admin",
            email="admin@questcity.com",
            password=hash_password("admin123"),
            first_name="System",
            last_name="Administrator",
            is_verified=True,
            is_active=True,
            role=3,  # Администратор
            can_edit_quests=True,
            can_lock_users=True,
            profile_id=profile.id
        )
        
        session.add(admin)
        await session.commit()
        
        print("✅ Администратор создан успешно!")
        print(f"   Username: admin")
        print(f"   Email: admin@questcity.com")
        print(f"   Password: admin123")
        print(f"   Role: Administrator")
        
        return admin

if __name__ == "__main__":
    print("🔧 Создание администратора...")
    asyncio.run(create_simple_admin()) 