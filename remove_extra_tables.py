#!/usr/bin/env python3
"""
Удаление лишних таблиц с сервера
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

def remove_extra_tables():
    """Удаление лишних таблиц"""
    print("🗑️ УДАЛЕНИЕ ЛИШНИХ ТАБЛИЦ")
    print("=" * 80)
    
    # Список лишних таблиц для удаления
    extra_tables = [
        'alembic_version',
        'chat',
        'chat_participant', 
        'email_verification_code',
        'favorite',
        'friend',
        'message',
        'point_type',
        'refresh_token',
        'reset_password_token',
        'review_response',
        'user'
    ]
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print(f"📋 Найдено {len(extra_tables)} лишних таблиц для удаления")
        
        for table_name in extra_tables:
            try:
                # Проверяем существование таблицы
                cursor.execute("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = %s
                    )
                """, (table_name,))
                
                table_exists = cursor.fetchone()[0]
                
                if table_exists:
                    # Удаляем таблицу
                    cursor.execute(f"DROP TABLE IF EXISTS {table_name} CASCADE")
                    print(f"  ✅ Таблица {table_name} удалена")
                else:
                    print(f"  ⚠️ Таблица {table_name} не существует")
                    
            except Exception as e:
                print(f"  ❌ Ошибка удаления таблицы {table_name}: {e}")
        
        cursor.close()
        conn.close()
        print("\n✅ Удаление лишних таблиц завершено!")
        
    except Exception as e:
        print(f"❌ Общая ошибка: {e}")

if __name__ == "__main__":
    remove_extra_tables()
