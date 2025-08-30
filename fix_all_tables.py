#!/usr/bin/env python3
"""
Исправление всех таблиц
"""
import psycopg2
import bcrypt

# Конфигурация серверной базы данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def hash_password(password):
    """Хеширует пароль с использованием bcrypt"""
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def fix_all_tables():
    """Исправляет все таблицы"""
    print("🔧 ИСПРАВЛЕНИЕ ВСЕХ ТАБЛИЦ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # 1. Исправляем таблицу category - добавляем первичный ключ
        print("\n🔧 Исправление таблицы category...")
        cursor.execute("ALTER TABLE category ADD CONSTRAINT category_pkey PRIMARY KEY (id)")
        print("  ✅ Первичный ключ добавлен к category")
        
        # 2. Исправляем таблицу profile - добавляем первичный ключ
        print("\n🔧 Исправление таблицы profile...")
        cursor.execute("ALTER TABLE profile ADD CONSTRAINT profile_pkey PRIMARY KEY (id)")
        print("  ✅ Первичный ключ добавлен к profile")
        
        # 3. Создаем таблицу quest
        print("\n🔧 Создание таблицы quest...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS quest (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                description TEXT NOT NULL,
                category_id INTEGER NOT NULL REFERENCES category(id),
                difficulty VARCHAR(50) NOT NULL,
                duration INTEGER NOT NULL,
                max_participants INTEGER NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                location VARCHAR(255) NOT NULL,
                coordinates JSONB,
                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
                updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
                owner_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE
            )
        """)
        print("  ✅ Таблица quest создана")
        
        # 4. Создаем таблицу point
        print("\n🔧 Создание таблицы point...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS point (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                description TEXT NOT NULL,
                coordinates JSONB NOT NULL,
                quest_id INTEGER NOT NULL REFERENCES quest(id) ON DELETE CASCADE,
                order_index INTEGER NOT NULL,
                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
                updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc', now()) NOT NULL
            )
        """)
        print("  ✅ Таблица point создана")
        
        # 5. Создаем админа
        print("\n🔧 Создание админа...")
        admin_password = hash_password("admin123")
        cursor.execute("""
            INSERT INTO "user" (
                username, first_name, last_name, full_name, password, email, 
                profile_id, role, is_active, is_verified, can_edit_quests, can_lock_users
            ) VALUES (
                'admin', 'Admin', 'User', 'Admin User', %s, 'admin@questcity.com',
                2, 2, true, true, true, true
            ) ON CONFLICT (email) DO NOTHING
        """, (admin_password,))
        print("  ✅ Админ создан")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_all_tables()
