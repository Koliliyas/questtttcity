#!/usr/bin/env python3
"""
Обновление ссылок user_id в таблице review
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

def update_review_user_references():
    """Обновление ссылок user_id в таблице review"""
    print("🔧 ОБНОВЛЕНИЕ ССЫЛОК USER_ID В ТАБЛИЦЕ REVIEW")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Получаем ID админа
        print("\n📋 Получение ID админа...")
        cursor.execute('SELECT id FROM "user" WHERE email = %s', ("admin@questcity.com",))
        admin_id = cursor.fetchone()
        
        if admin_id:
            admin_uuid = admin_id[0]
            print(f"  📋 ID админа: {admin_uuid}")
            
            # Проверяем текущие данные в review
            print("\n📋 Проверка текущих данных в review...")
            cursor.execute('SELECT id, user_id, owner_id FROM review')
            reviews = cursor.fetchall()
            print(f"  📊 Количество записей: {len(reviews)}")
            for review in reviews:
                print(f"    - ID: {review[0]}, user_id: {review[1]}, owner_id: {review[2]}")
            
            # Обновляем user_id для всех записей
            print("\n🔧 Обновление user_id...")
            cursor.execute('UPDATE review SET user_id = %s WHERE user_id IS NULL OR user_id != %s', (admin_uuid, admin_uuid))
            updated_count = cursor.rowcount
            print(f"  ✅ Обновлено записей: {updated_count}")
            
            # Проверяем результат
            print("\n📋 Проверка результата...")
            cursor.execute('SELECT id, user_id, owner_id FROM review')
            reviews_after = cursor.fetchall()
            print(f"  📊 Количество записей: {len(reviews_after)}")
            for review in reviews_after:
                print(f"    - ID: {review[0]}, user_id: {review[1]}, owner_id: {review[2]}")
            
        else:
            print("  ❌ Админ не найден")
        
        cursor.close()
        conn.close()
        print("\n✅ Ссылки обновлены!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    update_review_user_references()
