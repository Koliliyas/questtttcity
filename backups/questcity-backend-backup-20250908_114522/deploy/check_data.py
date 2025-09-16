#!/usr/bin/env python3
import asyncio
import asyncpg

async def check_data():
    try:
        conn = await asyncpg.connect(
            host='7da2c0adf39345ca39269f40.twc1.net',
            port=5432,
            user='gen_user',
            password='|dls1z:N7#v>vr',
            database='default_db',
            ssl='require'
        )
        
        print("🔍 Проверка данных в базе данных...")
        print("=" * 50)
        
        # Получаем список всех таблиц
        tables = await conn.fetch("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename")
        
        total_records = 0
        
        for table in tables:
            table_name = table['tablename']
            try:
                # Подсчитываем количество записей в таблице
                count = await conn.fetchval(f"SELECT COUNT(*) FROM {table_name}")
                print(f"📊 {table_name}: {count} записей")
                total_records += count
            except Exception as e:
                print(f"❌ Ошибка при проверке {table_name}: {e}")
        
        print("=" * 50)
        print(f"📈 Всего записей в базе данных: {total_records}")
        
        # Проверяем размер базы данных
        db_size = await conn.fetchval("SELECT pg_database_size('default_db')")
        print(f"💾 Размер базы данных: {db_size / 1024 / 1024:.2f} MB")
        
        await conn.close()
        
        if total_records == 0:
            print("\n⚠️ ВНИМАНИЕ: В базе данных нет записей!")
            print("Возможно, импорт данных не прошел успешно.")
        else:
            print(f"\n✅ Данные успешно импортированы! Всего записей: {total_records}")
        
    except Exception as e:
        print(f"❌ Ошибка подключения к БД: {e}")

if __name__ == "__main__":
    asyncio.run(check_data())











