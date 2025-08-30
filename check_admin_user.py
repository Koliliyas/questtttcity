#!/usr/bin/env python3
"""
Проверка админа в базе данных
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

def check_admin_user():
    """Проверяет админа в базе данных"""
    print("🔧 ПРОВЕРКА АДМИНА В БАЗЕ ДАННЫХ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем всех пользователей
        cursor.execute("SELECT id, email, username, role FROM \"user\"")
        users = cursor.fetchall()
        
        print(f"\n📊 Пользователи в базе данных ({len(users)}):")
        for user in users:
            print(f"  - ID: {user[0]}, Email: {user[1]}, Username: {user[2]}, Role: {user[3]}")
        
        # Проверяем админа
        cursor.execute("SELECT id, email, username, role, is_active, is_verified FROM \"user\" WHERE email = 'admin@questcity.com'")
        admin = cursor.fetchone()
        
        if admin:
            print(f"\n✅ Админ найден:")
            print(f"  - ID: {admin[0]}")
            print(f"  - Email: {admin[1]}")
            print(f"  - Username: {admin[2]}")
            print(f"  - Role: {admin[3]}")
            print(f"  - Is Active: {admin[4]}")
            print(f"  - Is Verified: {admin[5]}")
        else:
            print("\n❌ Админ не найден!")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_admin_user()
