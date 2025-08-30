#!/usr/bin/env python3
import psycopg2

def check_user():
    try:
        conn = psycopg2.connect(
            host="localhost",
            port="5432",
            database="questcity_db",
            user="postgres",
            password="postgres"
        )
        
        cur = conn.cursor()
        
        # Проверяем пользователя admin
        cur.execute("""
            SELECT id, username, email, role, can_edit_quests, can_lock_users 
            FROM "user" 
            WHERE email = 'admin@questcity.com'
        """)
        user = cur.fetchone()
        
        if user:
            print(f"📊 Пользователь admin:")
            print(f"  - ID: {user[0]}")
            print(f"  - Username: {user[1]}")
            print(f"  - Email: {user[2]}")
            print(f"  - Role: {user[3]} (0=USER, 1=MODERATOR, 2=ADMIN)")
            print(f"  - can_edit_quests: {user[4]}")
            print(f"  - can_lock_users: {user[5]}")
        else:
            print("❌ Пользователь admin не найден")
        
        # Проверяем всех пользователей
        cur.execute("""
            SELECT username, email, role, can_edit_quests, can_lock_users 
            FROM "user"
        """)
        users = cur.fetchall()
        
        print(f"\n📊 Всего пользователей: {len(users)}")
        for user in users:
            print(f"  - {user[0]} ({user[1]}) - Role: {user[2]}")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_user()



















