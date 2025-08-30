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

def test_create_profile():
    """Тест создания профиля"""
    print("🧪 ТЕСТ СОЗДАНИЯ ПРОФИЛЯ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем текущие данные
        print("\n📋 Текущие данные в profile:")
        cursor.execute('SELECT id, instagram_username, credits FROM profile ORDER BY id')
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
                RETURNING id
            """, ("testuser", 100))
            new_id = cursor.fetchone()[0]
            print(f"  ✅ Новый профиль создан с ID: {new_id}")
        except Exception as e:
            print(f"  ❌ Ошибка создания профиля: {e}")
        
        # Проверяем данные после создания
        print("\n📋 Данные в profile после создания:")
        cursor.execute('SELECT id, instagram_username, credits FROM profile ORDER BY id')
        profiles_after = cursor.fetchall()
        print(f"  📊 Количество записей: {len(profiles_after)}")
        for profile in profiles_after:
            print(f"    - ID: {profile[0]} | Instagram: {profile[1]} | Credits: {profile[2]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Тест завершен!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    test_create_profile()
