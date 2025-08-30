#!/usr/bin/env python3
import psycopg2

def fix_admin():
    try:
        conn = psycopg2.connect(
            host="localhost",
            port="5432",
            database="questcity_db",
            user="postgres",
            password="postgres"
        )
        
        cur = conn.cursor()
        
        # Обновляем права пользователя admin
        cur.execute("""
            UPDATE "user" 
            SET role = 2, can_edit_quests = true, can_lock_users = true
            WHERE email = 'admin@questcity.com'
        """)
        
        if cur.rowcount > 0:
            print("✅ Права администратора обновлены для пользователя admin")
        else:
            print("⚠️ Пользователь admin не найден")
        
        # Проверяем результат
        cur.execute("""
            SELECT username, email, role, can_edit_quests, can_lock_users 
            FROM "user" 
            WHERE email = 'admin@questcity.com'
        """)
        user = cur.fetchone()
        
        if user:
            print(f"📊 Обновленный пользователь admin:")
            print(f"  - Username: {user[0]}")
            print(f"  - Email: {user[1]}")
            print(f"  - Role: {user[2]} (0=USER, 1=MODERATOR, 2=ADMIN)")
            print(f"  - can_edit_quests: {user[3]}")
            print(f"  - can_lock_users: {user[4]}")
        
        conn.commit()
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_admin()
























