#!/usr/bin/env python3
"""
Изменение user.id с UUID на INTEGER
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

def fix_user_id_to_integer():
    """Изменение user.id с UUID на INTEGER"""
    print("🔧 ИЗМЕНЕНИЕ USER.ID С UUID НА INTEGER")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Создаем временную таблицу с INTEGER id
        print("\n🔧 Создание временной таблицы...")
        cursor.execute("""
            CREATE TABLE user_temp (
                id SERIAL PRIMARY KEY,
                email VARCHAR(255) NOT NULL,
                username VARCHAR(255) NOT NULL,
                password VARCHAR(255) NOT NULL,
                is_active BOOLEAN DEFAULT true,
                is_superuser BOOLEAN DEFAULT false,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                profile_id INTEGER,
                first_name VARCHAR(255),
                last_name VARCHAR(255),
                full_name VARCHAR(255),
                role VARCHAR(50),
                is_verified BOOLEAN DEFAULT false,
                can_edit_quests BOOLEAN DEFAULT false,
                can_lock_users BOOLEAN DEFAULT false
            )
        """)
        print("  ✅ Временная таблица создана")
        
        # Копируем данные из старой таблицы
        print("\n🔧 Копирование данных...")
        cursor.execute("""
            INSERT INTO user_temp (
                email, username, password, is_active, is_superuser, 
                created_at, updated_at, profile_id, first_name, last_name, 
                full_name, role, is_verified, can_edit_quests, can_lock_users
            ) SELECT 
                email, username, password, is_active, is_superuser, 
                created_at, updated_at, profile_id, first_name, last_name, 
                full_name, role, is_verified, can_edit_quests, can_lock_users
            FROM "user"
        """)
        print("  ✅ Данные скопированы")
        
        # Удаляем старую таблицу и переименовываем новую
        print("\n🔧 Замена таблицы...")
        cursor.execute('DROP TABLE "user"')
        cursor.execute('ALTER TABLE user_temp RENAME TO "user"')
        print("  ✅ Таблица заменена")
        
        # Обновляем profile_id для админа
        print("\n🔧 Обновление profile_id для админа...")
        cursor.execute('UPDATE "user" SET profile_id = 1 WHERE email = %s', ('admin@questcity.com',))
        print("  ✅ Profile_id обновлен")
        
        cursor.close()
        conn.close()
        print("\n✅ Изменение завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_user_id_to_integer()
