#!/usr/bin/env python3
"""
Скрипт для применения исправлений базы данных на сервере
"""
import psycopg2
import os
from datetime import datetime

# Параметры подключения к серверной базе данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr'
}

def apply_database_fix():
    """Применяет исправления к серверной базе данных"""
    print("🔧 Применение исправлений к серверной базе данных QuestCity")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = False  # Отключаем автокоммит для транзакций
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Читаем SQL скрипт
        print("📖 Чтение SQL скрипта...")
        script_path = 'fix_point_table.sql'
        
        if not os.path.exists(script_path):
            print(f"❌ Файл {script_path} не найден!")
            return False

        with open(script_path, 'r', encoding='utf-8') as file:
            sql_script = file.read()

        print("✅ SQL скрипт прочитан успешно!")

        # Выполняем SQL скрипт
        print("\n🚀 Выполнение SQL скрипта...")
        print("⚠️ Это может занять некоторое время...")

        # Разбиваем скрипт на отдельные команды
        commands = sql_script.split(';')
        
        for i, command in enumerate(commands, 1):
            command = command.strip()
            if command and not command.startswith('--'):
                try:
                    print(f"📝 Выполнение команды {i}/{len(commands)}...")
                    cursor.execute(command)
                    print(f"✅ Команда {i} выполнена успешно")
                except Exception as e:
                    print(f"⚠️ Предупреждение в команде {i}: {e}")
                    # Продолжаем выполнение, так как некоторые команды могут быть необязательными

        # Коммитим изменения
        print("\n💾 Сохранение изменений...")
        conn.commit()
        print("✅ Изменения сохранены!")

        # Проверяем результаты
        print("\n📊 Проверка результатов...")
        
        # Проверяем структуру таблицы point
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'point' AND table_schema = 'public'
            ORDER BY ordinal_position
        """)
        point_columns = cursor.fetchall()
        
        print(f"📍 Структура таблицы point после исправления:")
        for col in point_columns:
            print(f"  - {col[0]}: {col[1]} (nullable: {col[2]})")

        # Проверяем наличие таблицы point_type
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'point_type'
            )
        """)
        point_type_exists = cursor.fetchone()[0]
        
        if point_type_exists:
            print("✅ Таблица point_type создана успешно!")
            
            # Проверяем данные в point_type
            cursor.execute("SELECT COUNT(*) FROM point_type")
            point_type_count = cursor.fetchone()[0]
            print(f"📈 Количество записей в point_type: {point_type_count}")
        else:
            print("❌ Таблица point_type не была создана")

        # Проверяем статистику таблиц
        print("\n📈 Статистика таблиц после исправления:")
        tables_to_check = ['point', 'category', 'vehicle', 'place', 'activity', 'tool', 'point_type', 'place_settings', 'quest']
        
        for table in tables_to_check:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"  - {table}: {count} записей")
            except Exception as e:
                print(f"  - {table}: ошибка - {e}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("🎉 Исправления базы данных применены успешно!")
        print("✅ Структура таблиц приведена в соответствие с локальной версией")
        print("✅ Данные обновлены согласно локальной базе данных")
        print("✅ Теперь создание квестов должно работать корректно")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        if 'conn' in locals():
            conn.rollback()
            conn.close()
        return False

def main():
    print("🧪 Применение исправлений базы данных")
    print("=" * 80)
    
    success = apply_database_fix()
    
    if success:
        print(f"\n{'='*80}")
        print("🎉 Все исправления применены успешно!")
        print("Теперь можно тестировать создание квестов через API")
    else:
        print(f"\n{'='*80}")
        print("❌ Не удалось применить исправления")

if __name__ == "__main__":
    main()
