#!/usr/bin/env python3
"""
Скрипт для изменения роли пользователя на ADMIN
"""

import asyncio
import sys
from pathlib import Path

# Добавляем src в путь для импортов
sys.path.insert(0, str(Path(__file__).parent / "src"))

from sqlalchemy import update
from db.engine import async_session_factory
from db.models.user import User

async def change_user_role(email: str, new_role: int = 2):
    """Изменяет роль пользователя"""
    async with async_session_factory() as session:
        # Находим пользователя по email
        stmt = update(User).where(User.email == email).values(role=new_role)
        result = await session.execute(stmt)
        await session.commit()
        
        if result.rowcount > 0:
            print(f"✅ Роль пользователя {email} изменена на {new_role} (ADMIN)")
        else:
            print(f"❌ Пользователь {email} не найден")

async def main():
    """Основная функция"""
    email = "testuser@questcity.com"
    print(f"🔄 Изменение роли пользователя {email} на ADMIN...")
    
    await change_user_role(email, 2)
    
    print("✅ Готово!")

if __name__ == "__main__":
    asyncio.run(main()) 