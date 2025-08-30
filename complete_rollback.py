#!/usr/bin/env python3
"""
Полный откат к исходному состоянию базы данных
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

def complete_rollback():
    """Полный откат к исходному состоянию"""
    print("🔧 ПОЛНЫЙ ОТКАТ К ИСХОДНОМУ СОСТОЯНИЮ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Удаляем все таблицы, которые мы создавали или изменяли
        print("\n🔧 Удаление измененных таблиц...")
        
        tables_to_drop = [
            'review_response',
            'review', 
            'refresh_token',
            'reset_password_token',
            'email_verification_code',
            'alembic_version'
        ]
        
        for table in tables_to_drop:
            cursor.execute(f"DROP TABLE IF EXISTS {table} CASCADE")
            print(f"  ✅ Таблица {table} удалена")
        
        # Удаляем лишние колонки из таблицы user
        print("\n🔧 Удаление лишних колонок из user...")
        columns_to_drop = [
            'profile_id',
            'first_name', 
            'last_name',
            'full_name',
            'role',
            'is_verified',
            'can_edit_quests',
            'can_lock_users'
        ]
        
        for col in columns_to_drop:
            try:
                cursor.execute(f'ALTER TABLE "user" DROP COLUMN IF EXISTS {col}')
                print(f"  ✅ Колонка {col} удалена")
            except:
                pass
        
        # Удаляем лишние колонки из таблицы profile
        print("\n🔧 Удаление лишних колонок из profile...")
        profile_columns_to_drop = [
            'avatar_url',
            'bio',
            'phone',
            'birth_date',
            'gender',
            'location',
            'website',
            'social_links',
            'preferences',
            'settings'
        ]
        
        for col in profile_columns_to_drop:
            try:
                cursor.execute(f'ALTER TABLE profile DROP COLUMN IF EXISTS {col}')
                print(f"  ✅ Колонка {col} удалена")
            except:
                pass
        
        # Переименовываем password обратно в hashed_password
        print("\n🔧 Переименование password обратно в hashed_password...")
        try:
            cursor.execute('ALTER TABLE "user" RENAME COLUMN password TO hashed_password')
            print("  ✅ Колонка password переименована в hashed_password")
        except:
            pass
        
        # Переименовываем text обратно в review в таблице review (если она существует)
        print("\n🔧 Переименование text обратно в review...")
        try:
            cursor.execute('ALTER TABLE review RENAME COLUMN text TO review')
            print("  ✅ Колонка text переименована в review")
        except:
            pass
        
        cursor.close()
        conn.close()
        print("\n✅ Полный откат завершен!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    complete_rollback()
