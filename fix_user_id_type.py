#!/usr/bin/env python3
"""
Исправление типа колонки id в таблице user с INTEGER на UUID
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

def fix_user_id_type():
    """Исправление типа колонки id в таблице user"""
    print("🔧 ИСПРАВЛЕНИЕ ТИПА КОЛОНКИ ID В ТАБЛИЦЕ USER")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем текущий тип колонки id
        print("\n📋 Проверка текущего типа колонки id...")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'user' AND column_name = 'id'
        """)
        column_info = cursor.fetchone()
        
        if column_info:
            print(f"📊 Текущий тип: {column_info[0]} ({column_info[1]}, nullable: {column_info[2]})")
            
            if column_info[1] == 'integer':
                print("  🔧 Изменение типа с INTEGER на UUID...")
                try:
                    # Создаем временную таблицу с правильной структурой
                    cursor.execute("""
                        CREATE TABLE user_temp (
                            id UUID PRIMARY KEY,
                            email VARCHAR NOT NULL,
                            username VARCHAR NOT NULL,
                            password VARCHAR NOT NULL,
                            is_active BOOLEAN,
                            is_superuser BOOLEAN,
                            created_at TIMESTAMP WITH TIME ZONE,
                            updated_at TIMESTAMP WITH TIME ZONE,
                            profile_id INTEGER,
                            first_name VARCHAR(255),
                            last_name VARCHAR(255),
                            full_name VARCHAR(255),
                            role VARCHAR(50),
                            is_verified BOOLEAN DEFAULT FALSE,
                            can_edit_quests BOOLEAN DEFAULT FALSE,
                            can_lock_users BOOLEAN DEFAULT FALSE
                        )
                    """)
                    print("  ✅ Временная таблица создана")
                    
                    # Копируем данные, генерируя новые UUID
                    cursor.execute("""
                        INSERT INTO user_temp (
                            id, email, username, password, is_active, is_superuser,
                            created_at, updated_at, profile_id, first_name, last_name,
                            full_name, role, is_verified, can_edit_quests, can_lock_users
                        )
                        SELECT 
                            gen_random_uuid(), email, username, password, is_active, is_superuser,
                            created_at, updated_at, profile_id, first_name, last_name,
                            full_name, role, is_verified, can_edit_quests, can_lock_users
                        FROM "user"
                    """)
                    print("  ✅ Данные скопированы во временную таблицу")
                    
                    # Удаляем старую таблицу
                    cursor.execute('DROP TABLE "user" CASCADE')
                    print("  ✅ Старая таблица удалена")
                    
                    # Переименовываем временную таблицу
                    cursor.execute('ALTER TABLE user_temp RENAME TO "user"')
                    print("  ✅ Временная таблица переименована")
                    
                    # Проверяем результат
                    cursor.execute("""
                        SELECT column_name, data_type, is_nullable 
                        FROM information_schema.columns 
                        WHERE table_name = 'user' AND column_name = 'id'
                    """)
                    new_column_info = cursor.fetchone()
                    print(f"  📊 Новый тип: {new_column_info[0]} ({new_column_info[1]}, nullable: {new_column_info[2]})")
                    
                    # Проверяем данные
                    cursor.execute('SELECT id, email, username FROM "user"')
                    users = cursor.fetchall()
                    print(f"  📋 Количество пользователей: {len(users)}")
                    for user in users:
                        print(f"    - {user[0]} | {user[1]} | {user[2]}")
                    
                except Exception as e:
                    print(f"  ❌ Ошибка изменения типа: {e}")
            else:
                print("  ✅ Тип уже правильный (UUID)")
        else:
            print("  ❌ Колонка id не найдена")
        
        cursor.close()
        conn.close()
        print("\n✅ Тип колонки id исправлен!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_user_id_type()
