#!/usr/bin/env python3
"""
Проверка профиля админа
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

def check_admin_profile():
    """Проверка профиля админа"""
    print("🔍 ПРОВЕРКА ПРОФИЛЯ АДМИНА")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем данные админа
        print("\n📋 Данные админа:")
        cursor.execute('SELECT id, email, username, profile_id FROM "user" WHERE email = %s', ('admin@questcity.com',))
        admin = cursor.fetchone()
        
        if admin:
            print(f"  - ID: {admin[0]}")
            print(f"  - Email: {admin[1]}")
            print(f"  - Username: {admin[2]}")
            print(f"  - Profile ID: {admin[3]}")
            
            # Проверяем профиль админа
            if admin[3]:
                print(f"\n📋 Профиль админа (ID: {admin[3]}):")
                cursor.execute('SELECT id, instagram_username, credits FROM profile WHERE id = %s', (admin[3],))
                profile = cursor.fetchone()
                
                if profile:
                    print(f"  - ID: {profile[0]}")
                    print(f"  - Instagram: {profile[1]}")
                    print(f"  - Credits: {profile[2]}")
                else:
                    print("  ❌ Профиль не найден")
            else:
                print("  ❌ У админа нет profile_id")
        else:
            print("  ❌ Админ не найден")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_admin_profile()
