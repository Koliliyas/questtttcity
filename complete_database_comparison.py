#!/usr/bin/env python3
"""
Полное сравнение локальной и серверной базы данных
"""
import psycopg2
import json
from typing import Dict, List, Any, Tuple

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

def get_table_structure(conn, table_name: str) -> List[Dict[str, Any]]:
    """Получение структуры таблицы"""
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT 
                column_name,
                data_type,
                is_nullable,
                column_default,
                character_maximum_length,
                numeric_precision,
                numeric_scale
            FROM information_schema.columns 
            WHERE table_name = %s 
            ORDER BY ordinal_position
        """, (table_name,))
        
        columns = []
        for row in cursor.fetchall():
            columns.append({
                'name': row[0],
                'type': row[1],
                'nullable': row[2],
                'default': row[3],
                'max_length': row[4],
                'precision': row[5],
                'scale': row[6]
            })
        cursor.close()
        return columns
    except Exception as e:
        print(f"❌ Ошибка получения структуры таблицы {table_name}: {e}")
        return []

def get_table_data_sample(conn, table_name: str, limit: int = 5) -> List[Dict[str, Any]]:
    """Получение образца данных из таблицы"""
    try:
        cursor = conn.cursor()
        cursor.execute(f"SELECT * FROM {table_name} LIMIT {limit}")
        
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

def get_table_row_count(conn, table_name: str) -> int:
    """Получение количества строк в таблице"""
    try:
        cursor = conn.cursor()
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        cursor.close()
        return count
    except Exception as e:
        print(f"❌ Ошибка подсчета строк в таблице {table_name}: {e}")
        return -1

def compare_table_structures(local_structure: List[Dict], server_structure: List[Dict], table_name: str) -> Dict[str, Any]:
    """Сравнение структур таблиц"""
    differences = {
        'missing_columns': [],
        'extra_columns': [],
        'type_differences': [],
        'nullable_differences': []
    }
    
    local_columns = {col['name']: col for col in local_structure}
    server_columns = {col['name']: col for col in server_structure}
    
    # Проверяем отсутствующие колонки в сервере
    for col_name, local_col in local_columns.items():
        if col_name not in server_columns:
            differences['missing_columns'].append({
                'column': col_name,
                'local_type': local_col['type'],
                'local_nullable': local_col['nullable']
            })
    
    # Проверяем лишние колонки в сервере
    for col_name, server_col in server_columns.items():
        if col_name not in local_columns:
            differences['extra_columns'].append({
                'column': col_name,
                'server_type': server_col['type'],
                'server_nullable': server_col['nullable']
            })
    
    # Проверяем различия в типах и nullable
    for col_name in local_columns:
        if col_name in server_columns:
            local_col = local_columns[col_name]
            server_col = server_columns[col_name]
            
            if local_col['type'] != server_col['type']:
                differences['type_differences'].append({
                    'column': col_name,
                    'local_type': local_col['type'],
                    'server_type': server_col['type']
                })
            
            if local_col['nullable'] != server_col['nullable']:
                differences['nullable_differences'].append({
                    'column': col_name,
                    'local_nullable': local_col['nullable'],
                    'server_nullable': server_col['nullable']
                })
    
    return differences

def compare_databases():
    """Основная функция сравнения баз данных"""
    print("🔍 ПОЛНОЕ СРАВНЕНИЕ БАЗ ДАННЫХ")
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
    
    print(f"📊 Локальная БД: {len(local_tables)} таблиц")
    print(f"📊 Серверная БД: {len(server_tables)} таблиц")
    
    # Сравнение списков таблиц
    missing_tables = set(local_tables) - set(server_tables)
    extra_tables = set(server_tables) - set(local_tables)
    common_tables = set(local_tables) & set(server_tables)
    
    print(f"\n📋 Отсутствующие таблицы на сервере: {len(missing_tables)}")
    for table in sorted(missing_tables):
        print(f"  ❌ {table}")
    
    print(f"\n📋 Лишние таблицы на сервере: {len(extra_tables)}")
    for table in sorted(extra_tables):
        print(f"  ⚠️ {table}")
    
    print(f"\n📋 Общие таблицы: {len(common_tables)}")
    
    # Детальное сравнение общих таблиц
    all_differences = {}
    
    for table_name in sorted(common_tables):
        print(f"\n🔍 Анализ таблицы: {table_name}")
        print("-" * 60)
        
        # Получение структур
        local_structure = get_table_structure(local_conn, table_name)
        server_structure = get_table_structure(server_conn, table_name)
        
        # Получение количества строк
        local_count = get_table_row_count(local_conn, table_name)
        server_count = get_table_row_count(server_conn, table_name)
        
        print(f"📊 Количество строк: локальная={local_count}, серверная={server_count}")
        
        # Сравнение структур
        structure_diff = compare_table_structures(local_structure, server_structure, table_name)
        
        # Получение образцов данных
        local_sample = get_table_data_sample(local_conn, table_name, 3)
        server_sample = get_table_data_sample(server_conn, table_name, 3)
        
        table_differences = {
            'row_count_diff': local_count != server_count,
            'local_count': local_count,
            'server_count': server_count,
            'structure_differences': structure_diff,
            'local_sample': local_sample,
            'server_sample': server_sample
        }
        
        all_differences[table_name] = table_differences
        
        # Вывод различий
        if structure_diff['missing_columns']:
            print(f"  ❌ Отсутствующие колонки на сервере:")
            for col in structure_diff['missing_columns']:
                print(f"    - {col['column']} ({col['local_type']}, nullable: {col['local_nullable']})")
        
        if structure_diff['extra_columns']:
            print(f"  ⚠️ Лишние колонки на сервере:")
            for col in structure_diff['extra_columns']:
                print(f"    - {col['column']} ({col['server_type']}, nullable: {col['server_nullable']})")
        
        if structure_diff['type_differences']:
            print(f"  ⚠️ Различия в типах данных:")
            for col in structure_diff['type_differences']:
                print(f"    - {col['column']}: локальная={col['local_type']}, серверная={col['server_type']}")
        
        if structure_diff['nullable_differences']:
            print(f"  ⚠️ Различия в nullable:")
            for col in structure_diff['nullable_differences']:
                print(f"    - {col['column']}: локальная={col['local_nullable']}, серверная={col['server_nullable']}")
        
        if local_count != server_count:
            print(f"  ⚠️ Разное количество строк: {local_count} vs {server_count}")
        
        if not any([structure_diff['missing_columns'], structure_diff['extra_columns'], 
                   structure_diff['type_differences'], structure_diff['nullable_differences'], 
                   local_count != server_count]):
            print("  ✅ Таблица идентична")
    
    # Закрытие соединений
    local_conn.close()
    server_conn.close()
    
    # Сохранение отчета
    print(f"\n💾 Сохранение детального отчета...")
    with open('database_comparison_report.json', 'w', encoding='utf-8') as f:
        json.dump({
            'missing_tables': list(missing_tables),
            'extra_tables': list(extra_tables),
            'common_tables': list(common_tables),
            'table_differences': all_differences
        }, f, indent=2, ensure_ascii=False, default=str)
    
    print("✅ Отчет сохранен в database_comparison_report.json")
    
    # Итоговая сводка
    print(f"\n📊 ИТОГОВАЯ СВОДКА")
    print("=" * 80)
    print(f"📋 Всего таблиц в локальной БД: {len(local_tables)}")
    print(f"📋 Всего таблиц в серверной БД: {len(server_tables)}")
    print(f"❌ Отсутствующих таблиц на сервере: {len(missing_tables)}")
    print(f"⚠️ Лишних таблиц на сервере: {len(extra_tables)}")
    print(f"🔍 Общих таблиц: {len(common_tables)}")
    
    tables_with_differences = sum(1 for diff in all_differences.values() 
                                if any([diff['row_count_diff'], 
                                       diff['structure_differences']['missing_columns'],
                                       diff['structure_differences']['extra_columns'],
                                       diff['structure_differences']['type_differences'],
                                       diff['structure_differences']['nullable_differences']]))
    
    print(f"⚠️ Таблиц с различиями: {tables_with_differences}")
    print(f"✅ Идентичных таблиц: {len(common_tables) - tables_with_differences}")

if __name__ == "__main__":
    compare_databases()
