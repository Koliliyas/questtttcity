#!/usr/bin/env python3
"""
Создание таблицы user с админом
"""
import psycopg2
import bcrypt
import uuid

# Конфигурация серверной базы данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def create_user_table():
    """Создание таблицы user с админом"""
    print("🔧 СОЗДАНИЕ ТАБЛИЦЫ USER С АДМИНОМ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Создаем таблицу user
        print("\n📋 Создание таблицы user...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS "user" (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                email VARCHAR(255) UNIQUE NOT NULL,
                username VARCHAR(255) UNIQUE NOT NULL,
                hashed_password VARCHAR(255) NOT NULL,
                is_active BOOLEAN DEFAULT TRUE,
                is_superuser BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица user создана")
        
        # Создаем админа
        print("\n🔧 Создание админа...")
        
        # Хешируем пароль
        password = "admin123"
        hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        
        # Проверяем, есть ли уже админ
        cursor.execute('SELECT COUNT(*) FROM "user" WHERE email = %s', ("admin@questcity.com",))
        admin_exists = cursor.fetchone()[0] > 0
        
        if admin_exists:
            # Обновляем существующего админа
            cursor.execute('''
                UPDATE "user" 
                SET username = %s, hashed_password = %s, is_superuser = TRUE, is_active = TRUE
                WHERE email = %s
            ''', ("admin", hashed_password, "admin@questcity.com"))
            print("  ✅ Обновлен существующий админ")
        else:
            # Создаем нового админа
            cursor.execute('''
                INSERT INTO "user" (email, username, hashed_password, is_superuser, is_active)
                VALUES (%s, %s, %s, %s, %s)
            ''', ("admin@questcity.com", "admin", hashed_password, True, True))
            print("  ✅ Создан новый админ")
        
        # Проверяем результат
        cursor.execute('SELECT id, email, username, is_superuser, is_active FROM "user" WHERE email = %s', ("admin@questcity.com",))
        admin = cursor.fetchone()
        if admin:
            print(f"  📋 Админ: ID={admin[0]}, Email={admin[1]}, Username={admin[2]}, Superuser={admin[3]}, Active={admin[4]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Таблица user создана и админ настроен!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    create_user_table()
