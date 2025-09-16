#!/usr/bin/env python3
import asyncio
import sys
sys.path.insert(0, 'src')
from db.engine import async_session_factory
from db.models.user import User
from sqlalchemy import select

async def check_user_model():
    try:
        async with async_session_factory() as session:
            result = await session.execute(select(User))
            users = result.scalars().all()
            print(f'Пользователей найдено: {len(users)}')
            for user in users:
                print(f'  - {user.username} ({user.email})')
    except Exception as e:
        print(f'Ошибка: {e}')

if __name__ == "__main__":
    asyncio.run(check_user_model())
