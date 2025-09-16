#!/usr/bin/env python3
"""
Скрипт для импорта данных из SQL файла в базу данных
"""

import asyncio
import asyncpg
import sys

# Конфигурация серверной БД (Timeweb Cloud)
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'database': 'default_db',
    'sslmode': 'verify-full'
}

async def import_database(backup_file):
    """Импортирует данные в серверную БД"""
    print(f"🔄 Импорт данных из файла: {backup_file}")
    
    try:
        # Подключаемся к серверной БД
        conn = await asyncpg.connect(
            host=SERVER_DB_CONFIG['host'],
            port=SERVER_DB_CONFIG['port'],
            user=SERVER_DB_CONFIG['user'],
            password=SERVER_DB_CONFIG['password'],
            database=SERVER_DB_CONFIG['database'],
            ssl='require'
        )
        
        print("✅ Подключение к серверной БД установлено")
        
        # Читаем файл бэкапа
        with open(backup_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        print(f"📁 Размер файла: {len(content)} байт")
        
        # Разбиваем на отдельные команды
        commands = content.split(';')
        total_commands = len([cmd for cmd in commands if cmd.strip() and not cmd.strip().startswith('--')])
        
        print(f"📋 Всего команд для выполнения: {total_commands}")
        
        executed = 0
        for i, command in enumerate(commands):
            command = command.strip()
            if command and not command.startswith('--'):
                try:
                    await conn.execute(command)
                    executed += 1
                    if executed % 5 == 0:  # Прогресс каждые 5 команд
                        print(f"📥 Выполнено команд: {executed}/{total_commands}")
                except Exception as e:
                    print(f"⚠️ Ошибка в команде {i+1}: {e}")
                    print(f"Команда: {command[:100]}...")
        
        await conn.close()
        print(f"✅ Импорт завершен! Выполнено команд: {executed}")
        return True
        
    except Exception as e:
        print(f"❌ Ошибка импорта: {e}")
        return False

async def main():
    backup_file = "db_backup_20250827_002236.sql"
    
    print("🚀 Импорт данных в базу данных")
    print("=" * 50)
    
    success = await import_database(backup_file)
    
    if success:
        print("\n🎉 Импорт данных завершен успешно!")
    else:
        print("\n❌ Ошибка при импорте данных")
        sys.exit(1)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n❌ Импорт прерван пользователем")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Неожиданная ошибка: {e}")
        sys.exit(1)











