#!/usr/bin/env python3
"""
Синхронизация данных с локальной БД на серверную
"""
import psycopg2
import json
from typing import Dict, List, Any

# Конфигурация локальной базы данных
LOCAL_DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'questcity',
    'user': 'postgres',
    'password': 'postgres'
}

# Конфигурация серверной базы данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def get_connection(config: Dict[str, Any]):
    """Создание подключения к базе данных"""
    try:
        conn = psycopg2.connect(**config)
        return conn
    except Exception as e:
        print(f"❌ Ошибка подключения к БД: {e}")
        return None

def get_table_data(conn, table_name: str) -> List[Dict[str, Any]]:
    """Получение всех данных из таблицы"""
    try:
        cursor = conn.cursor()
        cursor.execute(f"SELECT * FROM {table_name} ORDER BY id")
        
        # Получаем названия колонок
        columns = [desc[0] for desc in cursor.description]
        
        # Получаем данные
        rows = cursor.fetchall()
        data = []
        for row in rows:
            row_dict = {}
            for i, value in enumerate(row):
                # Конвертируем в JSON-совместимый формат
                if isinstance(value, (bytes, bytearray)):
                    row_dict[columns[i]] = str(value)
                else:
                    row_dict[columns[i]] = value
            data.append(row_dict)
        
        cursor.close()
        return data
    except Exception as e:
        print(f"❌ Ошибка получения данных из таблицы {table_name}: {e}")
        return []

def get_table_structure(conn, table_name: str) -> List[str]:
    """Получение структуры таблицы"""
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT column_name FROM information_schema.columns 
            WHERE table_name = %s 
            ORDER BY ordinal_position
        """, (table_name,))
        columns = [row[0] for row in cursor.fetchall()]
        cursor.close()
        return columns
    except Exception as e:
        print(f"❌ Ошибка получения структуры таблицы {table_name}: {e}")
        return []

def sync_table_data(local_conn, server_conn, table_name: str):
    """Синхронизация данных таблицы"""
    print(f"\n🔄 Синхронизация таблицы: {table_name}")
    print("-" * 60)
    
    try:
        # Получаем данные из локальной БД
        local_data = get_table_data(local_conn, table_name)
        print(f"📊 Получено {len(local_data)} записей из локальной БД")
        
        if not local_data:
            print("  ⚠️ Локальная таблица пуста, пропускаем")
            return
        
        # Получаем структуру серверной таблицы
        server_columns = get_table_structure(server_conn, table_name)
        print(f"📋 Структура серверной таблицы: {server_columns}")
        
        # Очищаем серверную таблицу
        server_cursor = server_conn.cursor()
        server_cursor.execute(f"DELETE FROM {table_name}")
        print(f"  🗑️ Очищена серверная таблица {table_name}")
        
        # Подготавливаем данные для вставки
        for row in local_data:
            # Фильтруем только существующие колонки
            filtered_row = {k: v for k, v in row.items() if k in server_columns}
            
            # Формируем SQL для вставки
            columns = list(filtered_row.keys())
            values = list(filtered_row.values())
            placeholders = ', '.join(['%s'] * len(values))
            
            # Экранируем названия колонок для зарезервированных слов
            escaped_columns = [f'"{col}"' if col.lower() in ['user', 'group', 'order'] else col for col in columns]
            columns_str = ', '.join(escaped_columns)
            
            sql = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"
            
            try:
                server_cursor.execute(sql, values)
            except Exception as e:
                print(f"  ❌ Ошибка вставки записи {row.get('id', 'unknown')}: {e}")
                print(f"    SQL: {sql}")
                print(f"    Values: {values}")
                continue
        
        server_conn.commit()
        server_cursor.close()
        print(f"  ✅ Синхронизировано {len(local_data)} записей")
        
    except Exception as e:
        print(f"  ❌ Ошибка синхронизации таблицы {table_name}: {e}")

def sync_all_data():
    """Основная функция синхронизации"""
    print("🔄 СИНХРОНИЗАЦИЯ ДАННЫХ С ЛОКАЛЬНОЙ БД НА СЕРВЕРНУЮ")
    print("=" * 80)
    
    # Подключение к базам данных
    print("\n📡 Подключение к базам данных...")
    local_conn = get_connection(LOCAL_DB_CONFIG)
    server_conn = get_connection(SERVER_DB_CONFIG)
    
    if not local_conn or not server_conn:
        print("❌ Не удалось подключиться к одной из баз данных")
        return
    
    print("✅ Подключение успешно")
    
    # Список таблиц для синхронизации (только те, которые имеют данные)
    tables_to_sync = [
        'activity',
        'category', 
        'place',
        'profile',
        'tool',
        'vehicle'
    ]
    
    print(f"\n📋 Таблиц для синхронизации: {len(tables_to_sync)}")
    
    # Синхронизация каждой таблицы
    for table_name in tables_to_sync:
        sync_table_data(local_conn, server_conn, table_name)
    
    # Закрытие соединений
    local_conn.close()
    server_conn.close()
    
    print(f"\n✅ Синхронизация завершена!")
    print("📋 Синхронизированные таблицы:")
    for table in tables_to_sync:
        print(f"  - {table}")

if __name__ == "__main__":
    sync_all_data()
