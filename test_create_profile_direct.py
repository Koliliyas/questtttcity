#!/usr/bin/env python3
"""
Тест создания профиля напрямую в базе данных
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

def test_create_profile_direct():
    """Тест создания профиля напрямую в базе данных"""
    print("🧪 ТЕСТ СОЗДАНИЯ ПРОФИЛЯ НАПРЯМУЮ В БАЗЕ ДАННЫХ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем текущие данные
        print("\n📋 Текущие данные в таблице profile:")
        cursor.execute('SELECT id, instagram_username, credits FROM profile')
        profiles = cursor.fetchall()
        print(f"  📊 Количество записей: {len(profiles)}")
        for profile in profiles:
            print(f"    - ID: {profile[0]} | Instagram: {profile[1]} | Credits: {profile[2]}")
        
        # Пытаемся создать новый профиль
        print("\n📋 Попытка создания нового профиля...")
        try:
            cursor.execute("""
                INSERT INTO profile (instagram_username, credits) 
                VALUES (%s, %s)
            """, ("testuser", 100))
            print("  ✅ Профиль создан успешно")
            
            # Проверяем результат
            cursor.execute('SELECT id, instagram_username, credits FROM profile ORDER BY id DESC LIMIT 1')
            new_profile = cursor.fetchone()
            if new_profile:
                print(f"  📋 Новый профиль: ID={new_profile[0]}, Instagram={new_profile[1]}, Credits={new_profile[2]}")
            
        except Exception as e:
            print(f"  ❌ Ошибка создания профиля: {e}")
        
        cursor.close()
        conn.close()
        print("\n✅ Тест завершен!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    test_create_profile_direct()
