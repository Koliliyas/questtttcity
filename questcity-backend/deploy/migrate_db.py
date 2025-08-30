#!/usr/bin/env python3
"""
Скрипт для переноса данных с локальной БД на сервер Timeweb Cloud
"""

import os
import subprocess
import sys
from pathlib import Path

# Конфигурация локальной БД (из .env.backup)
LOCAL_DB_CONFIG = {
    'host': 'localhost',
    'port': '5432',
    'user': 'postgres',
    'password': 'postgres',
    'database': 'questcity_db'
}

# Конфигурация серверной БД (Timeweb Cloud)
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': '5432',
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
    from datetime import datetime
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return f"db_backup_{timestamp}.sql"

def main():
    print("🚀 Скрипт переноса данных с локальной БД на сервер")
    print("=" * 60)
    
    # Проверяем наличие pg_dump
    if not run_command("pg_dump --version", "Проверка pg_dump"):
        print("❌ pg_dump не найден. Установите PostgreSQL client tools.")
        return False
    
    # Создаем имя файла для бэкапа
    backup_file = create_backup_filename()
    
    # Формируем строки подключения
    local_connection = f"postgresql://{LOCAL_DB_CONFIG['user']}:{LOCAL_DB_CONFIG['password']}@{LOCAL_DB_CONFIG['host']}:{LOCAL_DB_CONFIG['port']}/{LOCAL_DB_CONFIG['database']}"
    
    server_connection = f"postgresql://{SERVER_DB_CONFIG['user']}:{SERVER_DB_CONFIG['password']}@{SERVER_DB_CONFIG['host']}:{SERVER_DB_CONFIG['port']}/{SERVER_DB_CONFIG['database']}?sslmode={SERVER_DB_CONFIG['sslmode']}"
    
    # Шаг 1: Создаем бэкап локальной БД
    dump_command = f"pg_dump '{local_connection}' > {backup_file}"
    if not run_command(dump_command, "Создание бэкапа локальной БД"):
        return False
    
    # Шаг 2: Проверяем размер файла
    file_size = Path(backup_file).stat().st_size
    print(f"📁 Размер файла бэкапа: {file_size / 1024 / 1024:.2f} MB")
    
    # Шаг 3: Загружаем файл на сервер
    upload_command = f"scp {backup_file} root@176.98.177.16:/opt/questcity/questcity-backend/"
    if not run_command(upload_command, "Загрузка файла на сервер"):
        return False
    
    # Шаг 4: Импортируем данные на сервере
    import_command = f"ssh root@176.98.177.16 'cd /opt/questcity/questcity-backend && psql \"{server_connection}\" < {backup_file}'"
    if not run_command(import_command, "Импорт данных на сервер"):
        return False
    
    # Шаг 5: Очищаем временные файлы
    cleanup_local = f"rm {backup_file}"
    cleanup_server = f"ssh root@176.98.177.16 'cd /opt/questcity/questcity-backend && rm {backup_file}'"
    
    run_command(cleanup_local, "Очистка локального файла")
    run_command(cleanup_server, "Очистка файла на сервере")
    
    print("\n🎉 Перенос данных завершен успешно!")
    print("=" * 60)
    return True

def interactive_setup():
    """Интерактивная настройка параметров БД"""
    print("🔧 Настройка параметров локальной базы данных")
    print("Введите параметры вашей локальной PostgreSQL БД:")
    
    config = {}
    config['host'] = input("Хост (localhost): ").strip() or 'localhost'
    config['port'] = input("Порт (5432): ").strip() or '5432'
    config['user'] = input("Пользователь: ").strip()
    config['password'] = input("Пароль: ").strip()
    config['database'] = input("База данных: ").strip()
    
    if not all([config['user'], config['password'], config['database']]):
        print("❌ Все поля обязательны для заполнения!")
        return None
    
    return config

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--setup":
        # Интерактивная настройка
        new_config = interactive_setup()
        if new_config:
            print("\n📝 Обновите LOCAL_DB_CONFIG в скрипте:")
            for key, value in new_config.items():
                print(f"    '{key}': '{value}',")
    else:
        # Проверяем, настроены ли параметры
        if LOCAL_DB_CONFIG['user'] == 'your_local_user':
            print("❌ Сначала настройте параметры локальной БД!")
            print("Запустите: python migrate_db.py --setup")
            sys.exit(1)
        
        success = main()
        sys.exit(0 if success else 1)
