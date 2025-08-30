#!/usr/bin/env python3
"""
Создание админа
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

def create_admin():
    """Создает админа"""
    print("🔧 СОЗДАНИЕ АДМИНА")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Создаем админа
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
        
        if cursor.rowcount > 0:
            print("  ✅ Админ создан успешно!")
        else:
            print("  ⚠️ Админ уже существует")
        
        # Проверяем создание
        cursor.execute("SELECT id, email, username, role FROM \"user\" WHERE email = 'admin@questcity.com'")
        admin = cursor.fetchone()
        
        if admin:
            print(f"  📊 Админ в базе: ID={admin[0]}, Email={admin[1]}, Username={admin[2]}, Role={admin[3]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Создание завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    create_admin()
