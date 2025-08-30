#!/usr/bin/env python3
"""
Обновление profile_id админа
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

def update_admin_profile_id():
    """Обновление profile_id админа"""
    print("🔧 ОБНОВЛЕНИЕ PROFILE_ID АДМИНА")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("🔧 Обновление profile_id админа...")
        
        # Обновляем profile_id админа
        cursor.execute('UPDATE "user" SET profile_id = 1 WHERE email = %s', ('admin@questcity.com',))
        print("  ✅ Profile ID обновлен")
        
        # Проверяем результат
        cursor.execute('SELECT id, email, username, profile_id FROM "user" WHERE email = %s', ('admin@questcity.com',))
        admin = cursor.fetchone()
        
        if admin:
            print(f"  📋 Результат: ID={admin[0]}, Email={admin[1]}, Username={admin[2]}, Profile ID={admin[3]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Обновление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    update_admin_profile_id()
