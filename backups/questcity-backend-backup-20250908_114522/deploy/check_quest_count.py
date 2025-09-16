#!/usr/bin/env python3
import asyncio
import asyncpg

async def check_quest_count():
    try:
        conn = await asyncpg.connect(
            host='localhost',
            port=5432,
            user='postgres',
            password='postgres',
            database='questcity_db'
        )
        
        count = await conn.fetchval('SELECT COUNT(*) FROM quest')
        print(f'📊 Квестов в локальной БД: {count}')
        
        # Также проверим другие важные таблицы
        activity_count = await conn.fetchval('SELECT COUNT(*) FROM activity')
        place_count = await conn.fetchval('SELECT COUNT(*) FROM place')
        user_count = await conn.fetchval('SELECT COUNT(*) FROM "user"')
        
        print(f'📊 Активностей: {activity_count}')
        print(f'📊 Мест: {place_count}')
        print(f'📊 Пользователей: {user_count}')
        
        await conn.close()
        
    except Exception as e:
        print(f'❌ Ошибка: {e}')

if __name__ == "__main__":
    asyncio.run(check_quest_count())











