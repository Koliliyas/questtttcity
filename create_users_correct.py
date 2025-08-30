#!/usr/bin/env python3
"""
Правильный скрипт для создания пользователей QuestCity в PostgreSQL
"""

import psycopg2
import uuid
from datetime import datetime

# Параметры подключения к базе данных
DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr'
}

def hash_password(password):
    """Хеширует пароль с использованием bcrypt"""
    import bcrypt
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def create_profile(cursor):
    """Создает профиль для пользователя"""
    cursor.execute("""
        INSERT INTO profile (created_at, updated_at)
        VALUES (NOW(), NOW())
        RETURNING id
    """)
    return cursor.fetchone()[0]

def create_users_in_db():
    """Создает пользователей в базе данных"""
    print("🚀 Создание пользователей QuestCity в базе данных")
    print("=" * 60)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключаемся к базе данных
        print("🔌 Подключение к базе данных...")
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение успешно!")

        # Создаем администратора
        print("\n👑 Создание администратора...")
        admin_id = str(uuid.uuid4())
        admin_email = "admin@questcity.com"
        admin_password = "Admin123!"
        admin_username = "admin"
        admin_first_name = "Admin"
        admin_last_name = "User"
        admin_full_name = f"{admin_first_name} {admin_last_name}"
        
        # Проверяем, существует ли уже администратор
        cursor.execute('SELECT id FROM "user" WHERE email = %s', (admin_email,))
        existing_admin = cursor.fetchone()
        
        if existing_admin:
            print("⚠️ Администратор уже существует!")
            # Обновляем пароль
            hashed_password = hash_password(admin_password)
            cursor.execute('''
                UPDATE "user" 
                SET password = %s 
                WHERE email = %s
            ''', (hashed_password, admin_email))
            print("✅ Пароль администратора обновлен")
        else:
            # Создаем профиль для администратора
            profile_id = create_profile(cursor)
            
            # Создаем нового администратора
            hashed_password = hash_password(admin_password)
            cursor.execute('''
                INSERT INTO "user" (
                    id, username, first_name, last_name, full_name, 
                    password, email, profile_id, role, is_active, 
                    is_verified, created_at, updated_at, can_edit_quests, can_lock_users
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW(), %s, %s)
            ''', (
                admin_id, admin_username, admin_first_name, admin_last_name, admin_full_name,
                hashed_password, admin_email, profile_id, 2, True, True, True, True
            ))
            print("✅ Администратор создан успешно!")

        # Создаем тестового пользователя
        print("\n👤 Создание тестового пользователя...")
        user_id = str(uuid.uuid4())
        user_email = "testuser@questcity.com"
        user_password = "Password123!"
        user_username = "testuser"
        user_first_name = "Test"
        user_last_name = "User"
        user_full_name = f"{user_first_name} {user_last_name}"
        
        # Проверяем, существует ли уже тестовый пользователь
        cursor.execute('SELECT id FROM "user" WHERE email = %s', (user_email,))
        existing_user = cursor.fetchone()
        
        if existing_user:
            print("⚠️ Тестовый пользователь уже существует!")
            # Обновляем пароль
            hashed_password = hash_password(user_password)
            cursor.execute('''
                UPDATE "user" 
                SET password = %s 
                WHERE email = %s
            ''', (hashed_password, user_email))
            print("✅ Пароль тестового пользователя обновлен")
        else:
            # Создаем профиль для тестового пользователя
            profile_id = create_profile(cursor)
            
            # Создаем нового тестового пользователя
            hashed_password = hash_password(user_password)
            cursor.execute('''
                INSERT INTO "user" (
                    id, username, first_name, last_name, full_name, 
                    password, email, profile_id, role, is_active, 
                    is_verified, created_at, updated_at, can_edit_quests, can_lock_users
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW(), %s, %s)
            ''', (
                user_id, user_username, user_first_name, user_last_name, user_full_name,
                hashed_password, user_email, profile_id, 0, True, True, False, False
            ))
            print("✅ Тестовый пользователь создан успешно!")

        # Сохраняем изменения
        conn.commit()
        print("\n💾 Изменения сохранены в базе данных")

        # Показываем всех пользователей
        print("\n📋 Все пользователи в базе данных:")
        cursor.execute('SELECT id, email, role, is_verified, created_at FROM "user" ORDER BY created_at')
        all_users = cursor.fetchall()
        
        for user in all_users:
            role_name = "ADMIN" if user[2] == 2 else "USER" if user[2] == 0 else "MODERATOR"
            print(f"  - ID: {user[0][:8]}..., Email: {user[1]}, Role: {role_name}, Verified: {user[3]}, Created: {user[4]}")

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Готово! Пользователи созданы в базе данных:")
        print("👑 Администратор: admin@questcity.com / Admin123!")
        print("👤 Пользователь: testuser@questcity.com / Password123!")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = create_users_in_db()
    
    if success:
        print("\n🎉 Теперь можно протестировать вход в приложение!")
    else:
        print("\n❌ Не удалось создать пользователей")

if __name__ == "__main__":
    main()

