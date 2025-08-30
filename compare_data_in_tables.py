#!/usr/bin/env python3
"""
Детальное сравнение данных во всех таблицах между локальной и серверной БД
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

def get_all_tables(conn) -> List[str]:
    """Получение списка всех таблиц"""
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        """)
        tables = [row[0] for row in cursor.fetchall()]
        cursor.close()
        return tables
    except Exception as e:
        print(f"❌ Ошибка получения таблиц: {e}")
        return []

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

def compare_table_data(local_data: List[Dict], server_data: List[Dict], table_name: str) -> Dict[str, Any]:
    """Сравнение данных в таблице"""
    differences = {
        'count_diff': len(local_data) != len(server_data),
        'local_count': len(local_data),
        'server_count': len(server_data),
        'missing_in_server': [],
        'extra_in_server': [],
        'data_differences': []
    }
    
    # Создаем словари для быстрого поиска по id
    local_dict = {str(row.get('id', i)): row for i, row in enumerate(local_data)}
    server_dict = {str(row.get('id', i)): row for i, row in enumerate(server_data)}
    
    # Проверяем отсутствующие записи в сервере
    for local_id, local_row in local_dict.items():
        if local_id not in server_dict:
            differences['missing_in_server'].append({
                'id': local_id,
                'local_data': local_row
            })
    
    # Проверяем лишние записи в сервере
    for server_id, server_row in server_dict.items():
        if server_id not in local_dict:
            differences['extra_in_server'].append({
                'id': server_id,
                'server_data': server_row
            })
    
    # Проверяем различия в данных для общих записей
    for local_id in local_dict:
        if local_id in server_dict:
            local_row = local_dict[local_id]
            server_row = server_dict[local_id]
            
            if local_row != server_row:
                differences['data_differences'].append({
                    'id': local_id,
                    'local_data': local_row,
                    'server_data': server_row
                })
    
    return differences

def compare_all_data():
    """Основная функция сравнения данных"""
    print("🔍 ДЕТАЛЬНОЕ СРАВНЕНИЕ ДАННЫХ В ТАБЛИЦАХ")
    print("=" * 80)
    
    # Подключение к базам данных
    print("\n📡 Подключение к базам данных...")
    local_conn = get_connection(LOCAL_DB_CONFIG)
    server_conn = get_connection(SERVER_DB_CONFIG)
    
    if not local_conn or not server_conn:
        print("❌ Не удалось подключиться к одной из баз данных")
        return
    
    print("✅ Подключение успешно")
    
    # Получение списков таблиц
    print("\n📋 Получение списков таблиц...")
    local_tables = get_all_tables(local_conn)
    server_tables = get_all_tables(server_conn)
    
    common_tables = set(local_tables) & set(server_tables)
    print(f"📊 Общих таблиц для сравнения: {len(common_tables)}")
    
    # Сравнение данных в каждой таблице
    all_differences = {}
    
    for table_name in sorted(common_tables):
        print(f"\n🔍 Сравнение данных в таблице: {table_name}")
        print("-" * 60)
        
        # Получение данных
        local_data = get_table_data(local_conn, table_name)
        server_data = get_table_data(server_conn, table_name)
        
        print(f"📊 Количество записей: локальная={len(local_data)}, серверная={len(server_data)}")
        
        # Сравнение данных
        differences = compare_table_data(local_data, server_data, table_name)
        all_differences[table_name] = differences
        
        # Вывод различий
        if differences['count_diff']:
            print(f"  ⚠️ Разное количество записей: {len(local_data)} vs {len(server_data)}")
        
        if differences['missing_in_server']:
            print(f"  ❌ Отсутствующие записи на сервере: {len(differences['missing_in_server'])}")
            for missing in differences['missing_in_server'][:3]:  # Показываем первые 3
                print(f"    - ID {missing['id']}: {missing['local_data']}")
            if len(differences['missing_in_server']) > 3:
                print(f"    ... и еще {len(differences['missing_in_server']) - 3} записей")
        
        if differences['extra_in_server']:
            print(f"  ⚠️ Лишние записи на сервере: {len(differences['extra_in_server'])}")
            for extra in differences['extra_in_server'][:3]:  # Показываем первые 3
                print(f"    - ID {extra['id']}: {extra['server_data']}")
            if len(differences['extra_in_server']) > 3:
                print(f"    ... и еще {len(differences['extra_in_server']) - 3} записей")
        
        if differences['data_differences']:
            print(f"  ⚠️ Различия в данных: {len(differences['data_differences'])} записей")
            for diff in differences['data_differences'][:3]:  # Показываем первые 3
                print(f"    - ID {diff['id']}:")
                print(f"      Локальная: {diff['local_data']}")
                print(f"      Серверная: {diff['server_data']}")
            if len(differences['data_differences']) > 3:
                print(f"    ... и еще {len(differences['data_differences']) - 3} различий")
        
        if not any([differences['count_diff'], differences['missing_in_server'], 
                   differences['extra_in_server'], differences['data_differences']]):
            print("  ✅ Данные идентичны")
    
    # Закрытие соединений
    local_conn.close()
    server_conn.close()
    
    # Сохранение отчета
    print(f"\n💾 Сохранение детального отчета...")
    with open('data_comparison_report.json', 'w', encoding='utf-8') as f:
        json.dump(all_differences, f, indent=2, ensure_ascii=False, default=str)
    
    print("✅ Отчет сохранен в data_comparison_report.json")
    
    # Итоговая сводка
    print(f"\n📊 ИТОГОВАЯ СВОДКА")
    print("=" * 80)
    
    tables_with_differences = sum(1 for diff in all_differences.values() 
                                if any([diff['count_diff'], diff['missing_in_server'], 
                                       diff['extra_in_server'], diff['data_differences']]))
    
    print(f"📋 Всего таблиц: {len(common_tables)}")
    print(f"⚠️ Таблиц с различиями в данных: {tables_with_differences}")
    print(f"✅ Таблиц с идентичными данными: {len(common_tables) - tables_with_differences}")
    
    if tables_with_differences > 0:
        print(f"\n📋 Таблицы с различиями:")
        for table_name, diff in all_differences.items():
            if any([diff['count_diff'], diff['missing_in_server'], 
                   diff['extra_in_server'], diff['data_differences']]):
                print(f"  - {table_name}: {diff['local_count']} vs {diff['server_count']} записей")

if __name__ == "__main__":
    compare_all_data()
