#!/usr/bin/env python3
"""
Простое восстановление базы данных из бэкапа
"""
import psycopg2

# Конфигурация серверной базы данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def restore_backup_simple():
    """Простое восстановление из бэкапа"""
    print("🔧 ПРОСТОЕ ВОССТАНОВЛЕНИЕ ИЗ БЭКАПА")
    print("=" * 80)
    
    try:
        # Читаем бэкап файл
        print("\n📋 Чтение бэкап файла...")
        backup_file = "./backup.sql"
        
        # Подключаемся к базе данных
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Выполняем команду для чтения файла на сервере
        print("  🔄 Выполняем восстановление...")
        
        # Выполняем SQL команды из бэкапа
        with open(backup_file, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Разбиваем на отдельные команды
        commands = sql_content.split(';')
        
        for i, command in enumerate(commands):
            command = command.strip()
            if command and not command.startswith('--'):
                try:
                    cursor.execute(command)
                    print(f"  ✅ Команда {i+1} выполнена")
                except Exception as e:
                    print(f"  ⚠️ Ошибка в команде {i+1}: {e}")
        
        cursor.close()
        conn.close()
        print("\n✅ Восстановление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    restore_backup_simple()
