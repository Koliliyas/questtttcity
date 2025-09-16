#!/usr/bin/env python3
import psycopg2

def verify_admin():
    try:
        conn = psycopg2.connect(
            host="localhost",
            port="5432",
            database="questcity_db",
            user="postgres",
            password="postgres"
        )
        
        cur = conn.cursor()
        
        # Верифицируем пользователя admin
        cur.execute("""
            UPDATE "user" 
            SET is_verified = true
            WHERE email = 'admin@questcity.com'
        """)
        
        if cur.rowcount > 0:
            print("✅ Пользователь admin верифицирован")
        else:
            print("⚠️ Пользователь admin не найден")
        
        # Проверяем результат
        cur.execute("""
            SELECT username, email, role, is_verified, can_edit_quests, can_lock_users 
            FROM "user" 
            WHERE email = 'admin@questcity.com'
        """)
        user = cur.fetchone()
        
        if user:
            print(f"📊 Обновленный пользователь admin:")
            print(f"  - Username: {user[0]}")
            print(f"  - Email: {user[1]}")
            print(f"  - Role: {user[2]} (0=USER, 1=MODERATOR, 2=ADMIN)")
            print(f"  - is_verified: {user[3]}")
            print(f"  - can_edit_quests: {user[4]}")
            print(f"  - can_lock_users: {user[5]}")
        
        conn.commit()
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    verify_admin()

































