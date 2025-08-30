#!/usr/bin/env python3
"""
Восстановление базы данных из бэкапа
"""
import psycopg2
import subprocess
import os

# Конфигурация серверной базы данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def get_all_tables():
    """Получает список всех таблиц в базе данных"""
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'public'
        """)
        
        tables = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return tables
        
    except Exception as e:
        print(f"❌ Ошибка получения таблиц: {e}")
        return []

def drop_all_tables(tables):
    """Удаляет все таблицы"""
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Удаление всех таблиц...")
        for table in tables:
            try:
                cursor.execute(f'DROP TABLE IF EXISTS "{table}" CASCADE')
                print(f"  ✅ Таблица {table} удалена")
            except Exception as e:
                print(f"  ⚠️ Не удалось удалить таблицу {table}: {e}")
        
        cursor.close()
        conn.close()
        print("✅ Все таблицы удалены")
        
    except Exception as e:
        print(f"❌ Ошибка удаления таблиц: {e}")

def restore_from_backup():
    """Восстанавливает базу данных из бэкапа"""
    print("🔧 ВОССТАНОВЛЕНИЕ БАЗЫ ДАННЫХ ИЗ БЭКАПА")
    print("=" * 80)
    
    # 1. Получаем список всех таблиц
    print("\n📋 Получение списка таблиц...")
    tables = get_all_tables()
    print(f"  📊 Найдено таблиц: {len(tables)}")
    
    # 2. Удаляем все таблицы
    if tables:
        drop_all_tables(tables)
    
    # 3. Восстанавливаем из бэкапа
    print("\n🔧 Восстановление из бэкапа...")
    backup_file = "/opt/questcity/questcity-backend/db_backup_proper_20250827_010710.sql"
    
    # Команда для восстановления
    restore_cmd = f"psql 'postgresql://gen_user:%7Cdls1z%3AN7%23v%3Evr@7da2c0adf39345ca39269f40.twc1.net:5432/default_db?sslmode=disable' -f {backup_file}"
    
    try:
        # Выполняем восстановление через SSH
        ssh_cmd = f"ssh root@176.98.177.16 '{restore_cmd}'"
        print(f"  🔄 Выполняем: {restore_cmd}")
        
        result = subprocess.run(ssh_cmd, shell=True, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("  ✅ База данных успешно восстановлена из бэкапа")
            print("  📄 Вывод:")
            print(result.stdout)
        else:
            print("  ❌ Ошибка восстановления:")
            print(result.stderr)
            
    except Exception as e:
        print(f"  ❌ Ошибка выполнения команды: {e}")

if __name__ == "__main__":
    restore_from_backup()
