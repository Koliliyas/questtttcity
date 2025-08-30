#!/usr/bin/env python3
"""
Проверка и исправление админа в таблице profile
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

def check_and_fix_admin():
    """Проверка и исправление админа"""
    print("🔍 ПРОВЕРКА И ИСПРАВЛЕНИЕ АДМИНА")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем текущие данные в profile
        print("\n📋 Проверка текущих данных в таблице profile...")
        cursor.execute("SELECT * FROM profile")
        profiles = cursor.fetchall()
        
        print(f"📊 Найдено {len(profiles)} профилей:")
        for profile in profiles:
            print(f"  - ID: {profile[0]}, Instagram: {profile[1]}, Credits: {profile[2]}")
        
        # Проверяем, есть ли таблица user или нужно создать админа в profile
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'user'
            )
        """)
        user_table_exists = cursor.fetchone()[0]
        
        if user_table_exists:
            print("\n📋 Таблица user существует, проверяем админа...")
            cursor.execute("SELECT * FROM \"user\"")
            users = cursor.fetchall()
            print(f"📊 Найдено {len(users)} пользователей:")
            for user in users:
                print(f"  - ID: {user[0]}, Email: {user[1]}, Username: {user[2]}")
        else:
            print("\n📋 Таблица user не существует")
            
            # Создаем админа в profile с правильными данными
            print("\n🔧 Создание админа в profile...")
            
            # Проверяем, есть ли уже профиль с ID 1
            cursor.execute("SELECT COUNT(*) FROM profile WHERE id = 1")
            profile_exists = cursor.fetchone()[0] > 0
            
            if profile_exists:
                # Обновляем существующий профиль
                cursor.execute("""
                    UPDATE profile 
                    SET instagram_username = 'admin', credits = 1000 
                    WHERE id = 1
                """)
                print("  ✅ Обновлен существующий профиль админа")
            else:
                # Создаем новый профиль
                cursor.execute("""
                    INSERT INTO profile (id, instagram_username, credits) 
                    VALUES (1, 'admin', 1000)
                """)
                print("  ✅ Создан новый профиль админа")
            
            # Проверяем результат
            cursor.execute("SELECT * FROM profile WHERE id = 1")
            admin_profile = cursor.fetchone()
            if admin_profile:
                print(f"  📋 Админ: ID={admin_profile[0]}, Instagram={admin_profile[1]}, Credits={admin_profile[2]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка и исправление завершены!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_and_fix_admin()
