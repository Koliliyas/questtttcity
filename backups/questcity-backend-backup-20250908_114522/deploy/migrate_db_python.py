#!/usr/bin/env python3
"""
Скрипт для переноса данных с локальной БД на сервер Timeweb Cloud
Использует Python вместо pg_dump
"""

import asyncio
import asyncpg
import subprocess
import sys
from pathlib import Path
from datetime import datetime

# Конфигурация локальной БД (из .env.backup)
LOCAL_DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'user': 'postgres',
    'password': 'postgres',
    'database': 'questcity_db'
}

# Конфигурация серверной БД (Timeweb Cloud)
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'database': 'default_db',
    'sslmode': 'verify-full'
}

def run_command(command, description):
    """Выполняет команду и выводит результат"""
    print(f"\n🔄 {description}")
    print(f"Команда: {command}")
    
    try:
        result = subprocess.run(command, shell=True, check=True, 
                              capture_output=True, text=True)
        print(f"✅ {description} - УСПЕШНО")
        if result.stdout:
            print(f"Вывод: {result.stdout}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} - ОШИБКА")
        print(f"Ошибка: {e.stderr}")
        return False

def create_backup_filename():
    """Создает имя файла для бэкапа с временной меткой"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return f"db_backup_{timestamp}.sql"

async def export_database():
    """Экспортирует базу данных используя Python"""
    print("🔄 Экспорт базы данных через Python...")
    
    try:
        # Подключаемся к локальной БД
        conn = await asyncpg.connect(
            host=LOCAL_DB_CONFIG['host'],
            port=LOCAL_DB_CONFIG['port'],
            user=LOCAL_DB_CONFIG['user'],
            password=LOCAL_DB_CONFIG['password'],
            database=LOCAL_DB_CONFIG['database']
        )
        
        print("✅ Подключение к локальной БД установлено")
        
        # Получаем список всех таблиц
        tables = await conn.fetch("""
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'public' 
            ORDER BY tablename
        """)
        
        print(f"📋 Найдено таблиц: {len(tables)}")
        
        # Создаем файл для бэкапа
        backup_file = create_backup_filename()
        
        with open(backup_file, 'w', encoding='utf-8') as f:
            # Записываем заголовок
            f.write("-- QuestCity Database Backup\n")
            f.write(f"-- Created: {datetime.now()}\n")
            f.write("-- Database: " + LOCAL_DB_CONFIG['database'] + "\n\n")
            
            # Экспортируем каждую таблицу
            for table in tables:
                table_name = table['tablename']
                print(f"📤 Экспорт таблицы: {table_name}")
                
                # Получаем структуру таблицы
                structure = await conn.fetch(f"""
                    SELECT column_name, data_type, is_nullable, column_default
                    FROM information_schema.columns 
                    WHERE table_name = $1 
                    ORDER BY ordinal_position
                """, table_name)
                
                # Создаем CREATE TABLE
                f.write(f"\n-- Table: {table_name}\n")
                f.write(f"DROP TABLE IF EXISTS {table_name} CASCADE;\n")
                f.write(f"CREATE TABLE {table_name} (\n")
                
                columns = []
                for col in structure:
                    col_def = f"    {col['column_name']} {col['data_type']}"
                    if col['is_nullable'] == 'NO':
                        col_def += " NOT NULL"
                    if col['column_default']:
                        col_def += f" DEFAULT {col['column_default']}"
                    columns.append(col_def)
                
                f.write(",\n".join(columns))
                f.write("\n);\n\n")
                
                # Получаем данные
                data = await conn.fetch(f"SELECT * FROM {table_name}")
                if data:
                    f.write(f"-- Data for table {table_name}\n")
                    for row in data:
                        values = []
                        for value in row.values():
                            if value is None:
                                values.append("NULL")
                            elif isinstance(value, str):
                                escaped_value = value.replace("'", "''")
                                values.append(f"'{escaped_value}'")
                            else:
                                values.append(str(value))
                        f.write(f"INSERT INTO {table_name} VALUES ({', '.join(values)});\n")
                    f.write("\n")
        
        await conn.close()
        print(f"✅ Экспорт завершен: {backup_file}")
        return backup_file
        
    except Exception as e:
        print(f"❌ Ошибка экспорта: {e}")
        return None

async def import_database(backup_file):
    """Импортирует данные в серверную БД"""
    print(f"🔄 Импорт данных в серверную БД...")
    
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
        
        # Читаем файл бэкапа и выполняем команды
        with open(backup_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Разбиваем на отдельные команды
        commands = content.split(';')
        
        for i, command in enumerate(commands):
            command = command.strip()
            if command and not command.startswith('--'):
                try:
                    await conn.execute(command)
                    if i % 10 == 0:  # Прогресс каждые 10 команд
                        print(f"📥 Выполнено команд: {i+1}/{len(commands)}")
                except Exception as e:
                    print(f"⚠️ Ошибка в команде {i+1}: {e}")
                    print(f"Команда: {command[:100]}...")
        
        await conn.close()
        print("✅ Импорт завершен")
        return True
        
    except Exception as e:
        print(f"❌ Ошибка импорта: {e}")
        return False

async def main():
    print("🚀 Скрипт переноса данных с локальной БД на сервер (Python)")
    print("=" * 70)
    
    # Шаг 1: Экспорт данных
    backup_file = await export_database()
    if not backup_file:
        return False
    
    # Шаг 2: Проверяем размер файла
    file_size = Path(backup_file).stat().st_size
    print(f"📁 Размер файла бэкапа: {file_size / 1024 / 1024:.2f} MB")
    
    # Шаг 3: Загружаем файл на сервер
    upload_command = f"scp {backup_file} root@176.98.177.16:/opt/questcity/questcity-backend/"
    if not run_command(upload_command, "Загрузка файла на сервер"):
        return False
    
    # Шаг 4: Импортируем данные на сервере
    print("🔄 Импорт данных на сервере...")
    import_command = f"ssh root@176.98.177.16 'cd /opt/questcity/questcity-backend && python3 -c \"import asyncio; from migrate_db_python import import_database; asyncio.run(import_database(\\\"{backup_file}\\\"))\"'"
    
    # Сначала копируем скрипт на сервер
    copy_script = f"scp migrate_db_python.py root@176.98.177.16:/opt/questcity/questcity-backend/"
    if not run_command(copy_script, "Копирование скрипта на сервер"):
        return False
    
    # Затем запускаем импорт
    if not run_command(import_command, "Импорт данных на сервере"):
        return False
    
    # Шаг 5: Очищаем временные файлы
    cleanup_local = f"rm {backup_file}"
    cleanup_server = f"ssh root@176.98.177.16 'cd /opt/questcity/questcity-backend && rm {backup_file} migrate_db_python.py'"
    
    run_command(cleanup_local, "Очистка локального файла")
    run_command(cleanup_server, "Очистка файлов на сервере")
    
    print("\n🎉 Перенос данных завершен успешно!")
    print("=" * 70)
    return True

if __name__ == "__main__":
    try:
        success = asyncio.run(main())
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n❌ Перенос прерван пользователем")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Неожиданная ошибка: {e}")
        sys.exit(1)
