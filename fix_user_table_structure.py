#!/usr/bin/env python3
"""
Исправление структуры таблицы user - добавление недостающих колонок
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

def fix_user_table_structure():
    """Исправление структуры таблицы user"""
    print("🔧 ИСПРАВЛЕНИЕ СТРУКТУРЫ ТАБЛИЦЫ USER")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем текущую структуру таблицы user
        print("\n📋 Проверка текущей структуры таблицы user...")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'user' 
            ORDER BY ordinal_position
        """)
        columns = cursor.fetchall()
        
        print("📊 Текущие колонки:")
        for col in columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]})")
        
        # Добавляем недостающие колонки
        print("\n🔧 Добавление недостающих колонок...")
        
        # Список колонок, которые нужно добавить
        missing_columns = [
            ("profile_id", "INTEGER", "NULL"),
            ("first_name", "VARCHAR(255)", "NULL"),
            ("last_name", "VARCHAR(255)", "NULL"),
            ("full_name", "VARCHAR(255)", "NULL"),
            ("role", "VARCHAR(50)", "NULL"),
            ("is_verified", "BOOLEAN", "DEFAULT FALSE"),
            ("can_edit_quests", "BOOLEAN", "DEFAULT FALSE"),
            ("can_lock_users", "BOOLEAN", "DEFAULT FALSE")
        ]
        
        existing_columns = [col[0] for col in columns]
        
        for col_name, col_type, nullable in missing_columns:
            if col_name not in existing_columns:
                try:
                    sql = f'ALTER TABLE "user" ADD COLUMN {col_name} {col_type} {nullable}'
                    cursor.execute(sql)
                    print(f"  ✅ Добавлена колонка {col_name}")
                except Exception as e:
                    print(f"  ❌ Ошибка добавления колонки {col_name}: {e}")
            else:
                print(f"  ⚠️ Колонка {col_name} уже существует")
        
        # Обновляем данные для админа
        print("\n🔧 Обновление данных админа...")
        try:
            cursor.execute('''
                UPDATE "user" 
                SET 
                    first_name = 'Admin',
                    last_name = 'User',
                    full_name = 'Admin User',
                    role = 'admin',
                    is_verified = TRUE,
                    can_edit_quests = TRUE,
                    can_lock_users = TRUE,
                    profile_id = 1
                WHERE email = 'admin@questcity.com'
            ''')
            print("  ✅ Данные админа обновлены")
        except Exception as e:
            print(f"  ❌ Ошибка обновления данных админа: {e}")
        
        # Проверяем результат
        print("\n📋 Проверка обновленной структуры...")
        cursor.execute("""
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'user' 
            ORDER BY ordinal_position
        """)
        updated_columns = cursor.fetchall()
        
        print("📊 Обновленные колонки:")
        for col in updated_columns:
            print(f"  - {col[0]} ({col[1]}, nullable: {col[2]})")
        
        # Проверяем данные админа
        print("\n📋 Проверка данных админа...")
        cursor.execute('SELECT id, email, username, first_name, last_name, role, profile_id FROM "user" WHERE email = %s', ("admin@questcity.com",))
        admin = cursor.fetchone()
        if admin:
            print(f"  📋 Админ: ID={admin[0]}, Email={admin[1]}, Username={admin[2]}, FirstName={admin[3]}, LastName={admin[4]}, Role={admin[5]}, ProfileID={admin[6]}")
        
        cursor.close()
        conn.close()
        print("\n✅ Структура таблицы user исправлена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_user_table_structure()
