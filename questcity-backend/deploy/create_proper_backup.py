#!/usr/bin/env python3
"""
Скрипт для создания правильного бэкапа базы данных
с корректным форматированием для импорта
"""

import asyncio
import asyncpg
import sys
from pathlib import Path
from datetime import datetime

# Конфигурация локальной БД
LOCAL_DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'user': 'postgres',
    'password': 'postgres',
    'database': 'questcity_db'
}

def create_backup_filename():
    """Создает имя файла для бэкапа с временной меткой"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return f"db_backup_proper_{timestamp}.sql"

async def export_database_proper():
    """Экспортирует базу данных с правильным форматированием"""
    print("🔄 Создание правильного бэкапа базы данных...")
    
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
            f.write("-- QuestCity Database Backup (Proper Format)\n")
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
                                # Экранируем кавычки
                                escaped_value = value.replace("'", "''")
                                values.append(f"'{escaped_value}'")
                            elif isinstance(value, datetime):
                                # Правильно форматируем даты
                                values.append(f"'{value.isoformat()}'")
                            elif isinstance(value, bool):
                                # Правильно форматируем булевы значения
                                values.append("true" if value else "false")
                            else:
                                values.append(str(value))
                        f.write(f"INSERT INTO {table_name} VALUES ({', '.join(values)});\n")
                    f.write("\n")
        
        await conn.close()
        print(f"✅ Правильный бэкап создан: {backup_file}")
        
        # Показываем размер файла
        file_size = Path(backup_file).stat().st_size
        print(f"📁 Размер файла: {file_size / 1024:.2f} KB")
        
        return backup_file
        
    except Exception as e:
        print(f"❌ Ошибка экспорта: {e}")
        return None

async def main():
    print("🚀 Создание правильного бэкапа QuestCity Database")
    print("=" * 60)
    
    backup_file = await export_database_proper()
    
    if backup_file:
        print(f"\n🎉 Бэкап успешно создан: {backup_file}")
        print("Теперь можно загрузить этот файл на сервер и импортировать данные.")
    else:
        print("\n❌ Ошибка при создании бэкапа")
        sys.exit(1)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n❌ Экспорт прерван пользователем")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Неожиданная ошибка: {e}")
        sys.exit(1)



