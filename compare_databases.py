#!/usr/bin/env python3
"""
Скрипт для сравнения локальной и серверной баз данных QuestCity
"""
import psycopg2
from datetime import datetime

# Параметры подключения к локальной базе данных
LOCAL_DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'questcity',
    'user': 'postgres',
    'password': 'postgres'
}

# Параметры подключения к серверной базе данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr'
}

def compare_databases():
    """Сравнивает локальную и серверную базы данных"""
    print("🔍 Сравнение локальной и серверной баз данных QuestCity")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к локальной базе
        print("🔗 Подключение к локальной базе данных...")
        local_conn = psycopg2.connect(**LOCAL_DB_CONFIG)
        local_cursor = local_conn.cursor()
        print("✅ Подключение к локальной базе успешно!")

        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        server_conn = psycopg2.connect(**SERVER_DB_CONFIG)
        server_cursor = server_conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Список таблиц для сравнения
        tables_to_compare = [
            'category', 'vehicle', 'place', 'activity', 'tool', 
            'point', 'point_type', 'user', 'profile', 'quest'
        ]

        print(f"\n📊 Сравнение таблиц:")
        print("=" * 80)

        for table_name in tables_to_compare:
            print(f"\n🏷️ Таблица: {table_name}")
            print("-" * 40)

            # Проверяем существование таблицы в локальной базе
            local_cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = %s
                )
            """, (table_name,))
            local_exists = local_cursor.fetchone()[0]

            # Проверяем существование таблицы в серверной базе
            server_cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = %s
                )
            """, (table_name,))
            server_exists = server_cursor.fetchone()[0]

            if not local_exists and not server_exists:
                print(f"❌ Таблица {table_name} не существует ни в одной базе")
                continue

            if not local_exists:
                print(f"❌ Таблица {table_name} отсутствует в локальной базе")
                continue

            if not server_exists:
                print(f"❌ Таблица {table_name} отсутствует в серверной базе")
                continue

            # Получаем количество записей в локальной базе
            local_cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            local_count = local_cursor.fetchone()[0]

            # Получаем количество записей в серверной базе
            server_cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            server_count = server_cursor.fetchone()[0]

            print(f"📈 Локальная база: {local_count} записей")
            print(f"📈 Серверная база: {server_count} записей")

            if local_count != server_count:
                print(f"⚠️ РАЗЛИЧИЕ: Количество записей отличается на {abs(local_count - server_count)}")

            # Сравниваем структуру таблицы
            print(f"🔧 Сравнение структуры таблицы {table_name}:")
            
            # Получаем структуру локальной таблицы
            local_cursor.execute("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns 
                WHERE table_name = %s AND table_schema = 'public'
                ORDER BY ordinal_position
            """, (table_name,))
            local_columns = local_cursor.fetchall()

            # Получаем структуру серверной таблицы
            server_cursor.execute("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns 
                WHERE table_name = %s AND table_schema = 'public'
                ORDER BY ordinal_position
            """, (table_name,))
            server_columns = server_cursor.fetchall()

            local_cols_set = {(col[0], col[1], col[2]) for col in local_columns}
            server_cols_set = {(col[0], col[1], col[2]) for col in server_columns}

            if local_cols_set != server_cols_set:
                print(f"⚠️ РАЗЛИЧИЕ: Структура таблицы отличается!")
                
                # Показываем различия
                local_only = local_cols_set - server_cols_set
                server_only = server_cols_set - local_cols_set
                
                if local_only:
                    print(f"  📍 Только в локальной базе:")
                    for col in local_only:
                        print(f"    - {col[0]}: {col[1]} (nullable: {col[2]})")
                
                if server_only:
                    print(f"  📍 Только в серверной базе:")
                    for col in server_only:
                        print(f"    - {col[0]}: {col[1]} (nullable: {col[2]})")
            else:
                print(f"✅ Структура таблицы идентична")

            # Показываем несколько примеров данных
            if local_count > 0:
                print(f"📋 Примеры данных из локальной базы:")
                local_cursor.execute(f"SELECT * FROM {table_name} LIMIT 3")
                local_samples = local_cursor.fetchall()
                for i, sample in enumerate(local_samples, 1):
                    print(f"  {i}. {sample}")

            if server_count > 0:
                print(f"📋 Примеры данных из серверной базы:")
                server_cursor.execute(f"SELECT * FROM {table_name} LIMIT 3")
                server_samples = server_cursor.fetchall()
                for i, sample in enumerate(server_samples, 1):
                    print(f"  {i}. {sample}")

        # Закрываем соединения
        local_cursor.close()
        local_conn.close()
        server_cursor.close()
        server_conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Сравнение завершено")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = compare_databases()
    
    if not success:
        print("\n❌ Не удалось сравнить базы данных")

if __name__ == "__main__":
    main()

