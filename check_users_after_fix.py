#!/usr/bin/env python3
"""
Скрипт для проверки пользователей после исправления базы данных
"""
import psycopg2
from datetime import datetime

# Параметры подключения к серверной базе данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr'
}

def check_users_after_fix():
    """Проверяет пользователей после исправления базы данных"""
    print("🔍 Проверка пользователей после исправления базы данных")
    print("=" * 80)
    print(f"📅 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    try:
        # Подключение к серверной базе
        print("🔗 Подключение к серверной базе данных...")
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Подключение к серверной базе успешно!")

        # Проверяем таблицу user
        print("\n👥 Проверка таблицы user:")
        cursor.execute("SELECT COUNT(*) FROM \"user\"")
        user_count = cursor.fetchone()[0]
        print(f"📈 Количество пользователей: {user_count}")

        if user_count > 0:
            cursor.execute("SELECT id, email, username, is_active FROM \"user\" LIMIT 10")
            users = cursor.fetchall()
            print(f"✅ Примеры пользователей:")
            for user in users:
                print(f"  - ID: {user[0]}, Email: {user[1]}, Username: {user[2]}, Active: {user[3]}")

        # Проверяем таблицу profile
        print("\n👤 Проверка таблицы profile:")
        cursor.execute("SELECT COUNT(*) FROM profile")
        profile_count = cursor.fetchone()[0]
        print(f"📈 Количество профилей: {profile_count}")

        if profile_count > 0:
            cursor.execute("SELECT id, user_id, first_name, last_name FROM profile LIMIT 10")
            profiles = cursor.fetchall()
            print(f"✅ Примеры профилей:")
            for profile in profiles:
                print(f"  - ID: {profile[0]}, User ID: {profile[1]}, Name: {profile[2]} {profile[3]}")

        # Проверяем конкретного админа
        print("\n🔍 Поиск админа:")
        cursor.execute("SELECT id, email, username, is_active FROM \"user\" WHERE email = 'admin@questcity.com'")
        admin = cursor.fetchone()
        
        if admin:
            print(f"✅ Админ найден:")
            print(f"  - ID: {admin[0]}")
            print(f"  - Email: {admin[1]}")
            print(f"  - Username: {admin[2]}")
            print(f"  - Active: {admin[3]}")
            
            # Проверяем профиль админа
            cursor.execute("SELECT id, user_id, first_name, last_name FROM profile WHERE user_id = %s", (admin[0],))
            admin_profile = cursor.fetchone()
            
            if admin_profile:
                print(f"✅ Профиль админа найден:")
                print(f"  - Profile ID: {admin_profile[0]}")
                print(f"  - User ID: {admin_profile[1]}")
                print(f"  - Name: {admin_profile[2]} {admin_profile[3]}")
            else:
                print("❌ Профиль админа не найден")
        else:
            print("❌ Админ не найден")

        # Создаем админа если его нет
        if not admin:
            print("\n📝 Создание админа...")
            try:
                # Создаем пользователя
                cursor.execute("""
                    INSERT INTO "user" (email, username, hashed_password, is_active, is_superuser)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id
                """, ('admin@questcity.com', 'admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK2.', True, True))
                
                user_id = cursor.fetchone()[0]
                print(f"✅ Пользователь создан с ID: {user_id}")
                
                # Создаем профиль
                cursor.execute("""
                    INSERT INTO profile (user_id, first_name, last_name)
                    VALUES (%s, %s, %s)
                """, (user_id, 'Admin', 'User'))
                
                print("✅ Профиль админа создан")
                
                # Коммитим изменения
                conn.commit()
                print("✅ Изменения сохранены")
                
            except Exception as e:
                print(f"❌ Ошибка при создании админа: {e}")
                conn.rollback()

        cursor.close()
        conn.close()
        
        print("\n" + "=" * 80)
        print("✅ Проверка завершена")
        
        return True

    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    success = check_users_after_fix()
    
    if not success:
        print("\n❌ Не удалось проверить пользователей")

if __name__ == "__main__":
    main()
