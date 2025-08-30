#!/usr/bin/env python3
"""
Скрипт для прямого запроса merchandise данных из базы
"""

import asyncio
import os
import asyncpg

async def test_merch_direct_db():
    """Прямой запрос merchandise данных из базы"""
    
    print("🧪 Прямой запрос merchandise данных из базы")
    
    try:
        # Подключаемся к базе данных
        conn = await asyncpg.connect(
            host='localhost',
            port=5432,
            user='postgres',
            password='postgres',
            database='questcity_db'
        )
        
        print("✅ Подключение к базе данных установлено")
        
        # Проверяем merchandise для квеста ID 64
        print(f"\n🔍 Проверяем merchandise для квеста ID 64...")
        merch_rows = await conn.fetch(
            "SELECT id, description, price, image, quest_id FROM merch WHERE quest_id = $1",
            64
        )
        
        print(f"📊 Результат запроса:")
        print(f"  - Найдено записей: {len(merch_rows)}")
        for i, row in enumerate(merch_rows):
            print(f"  - merch[{i}]: id={row['id']}, description='{row['description']}', price={row['price']}, quest_id={row['quest_id']}")
        
        # Проверяем все merchandise записи
        print(f"\n🔍 Проверяем все merchandise записи...")
        all_merch_rows = await conn.fetch(
            "SELECT id, description, price, image, quest_id FROM merch ORDER BY id"
        )
        
        print(f"📊 Все merchandise записи:")
        print(f"  - Всего записей: {len(all_merch_rows)}")
        for i, row in enumerate(all_merch_rows):
            print(f"  - merch[{i}]: id={row['id']}, description='{row['description']}', price={row['price']}, quest_id={row['quest_id']}")
        
        await conn.close()
        print("✅ Соединение с базой данных закрыто")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_merch_direct_db())


