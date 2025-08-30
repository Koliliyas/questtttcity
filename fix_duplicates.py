#!/usr/bin/env python3
"""
Скрипт для удаления дублированных данных в базе QuestCity
"""
import psycopg2
from datetime import datetime

# Параметры подключения к базе данных
DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr'
}

def fix_duplicates():
    """Удаляет дублированные данные из базы"""
    print("🔧 Исправление дублированных данных в базе QuestCity")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение успешно!")

        # Список таблиц для очистки
        tables = [
            ('category', 'id'),
            ('vehicle', 'id'), 
            ('place', 'id'),
            ('activity', 'id'),
            ('tool', 'id')
        ]

        for table_name, id_column in tables:
            print(f"\n🧹 Очистка дубликатов в таблице {table_name}:")
            
            # Сначала проверяем количество записей
            cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            before_count = cursor.fetchone()[0]
            print(f"  📊 Записей до очистки: {before_count}")
            
            # Удаляем дубликаты, оставляя только первую запись для каждого ID
            cursor.execute(f"""
                DELETE FROM {table_name} 
                WHERE ctid NOT IN (
                    SELECT MIN(ctid) 
                    FROM {table_name} 
                    GROUP BY {id_column}
                )
            """)
            
            deleted_count = cursor.rowcount
            print(f"  🗑️ Удалено дубликатов: {deleted_count}")
            
            # Проверяем количество записей после очистки
            cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            after_count = cursor.fetchone()[0]
            print(f"  📊 Записей после очистки: {after_count}")

        # Сохраняем изменения
        conn.commit()
        print(f"\n💾 Изменения сохранены в базе данных")

        # Проверяем результат
        print(f"\n✅ Проверка результата:")
        for table_name, id_column in tables:
            cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            count = cursor.fetchone()[0]
            print(f"  - {table_name}: {count} записей")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Очистка дубликатов завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        if 'conn' in locals():
            conn.rollback()
        return False

def main():
    print("⚠️ ВНИМАНИЕ: Этот скрипт удалит дублированные данные из базы!")
    print("Убедитесь, что у вас есть резервная копия базы данных.")
    
    response = input("\nПродолжить? (y/N): ")
    if response.lower() != 'y':
        print("❌ Операция отменена")
        return
    
    success = fix_duplicates()
    
    if success:
        print("\n🎉 Дубликаты успешно удалены!")
        print("Теперь можно протестировать создание квеста.")
    else:
        print("\n❌ Не удалось удалить дубликаты")

if __name__ == "__main__":
    main()

