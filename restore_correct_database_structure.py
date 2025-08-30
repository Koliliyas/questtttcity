#!/usr/bin/env python3
"""
Восстановление правильной структуры базы данных
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

def hash_password(password):
    """Хеширует пароль с использованием bcrypt"""
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def restore_correct_database_structure():
    """Восстановление правильной структуры базы данных"""
    print("🔧 ВОССТАНОВЛЕНИЕ ПРАВИЛЬНОЙ СТРУКТУРЫ БАЗЫ ДАННЫХ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # 1. Удаляем все таблицы, которые мы создавали
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
        
        # 2. Восстанавливаем таблицу user с UUID id
        print("\n🔧 Восстановление таблицы user с UUID id...")
        
        # Создаем временную таблицу с UUID id
        cursor.execute("""
            CREATE TABLE user_temp (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                email VARCHAR(255) NOT NULL UNIQUE,
                username VARCHAR(255) NOT NULL UNIQUE,
                password VARCHAR(255) NOT NULL,
                is_active BOOLEAN DEFAULT true,
                is_superuser BOOLEAN DEFAULT false,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                profile_id INTEGER REFERENCES profile(id),
                first_name VARCHAR(255),
                last_name VARCHAR(255),
                full_name VARCHAR(255),
                role VARCHAR(50) DEFAULT 'user',
                is_verified BOOLEAN DEFAULT false,
                can_edit_quests BOOLEAN DEFAULT false,
                can_lock_users BOOLEAN DEFAULT false
            )
        """)
        print("  ✅ Временная таблица user создана")
        
        # Копируем данные из старой таблицы
        cursor.execute("""
            INSERT INTO user_temp (
                email, username, password, is_active, is_superuser, 
                created_at, updated_at, profile_id, first_name, last_name, 
                full_name, role, is_verified, can_edit_quests, can_lock_users
            ) SELECT 
                email, username, password, is_active, is_superuser, 
                created_at, updated_at, profile_id, first_name, last_name, 
                full_name, role, is_verified, can_edit_quests, can_lock_users
            FROM "user"
        """)
        print("  ✅ Данные скопированы")
        
        # Удаляем старую таблицу и переименовываем новую
        cursor.execute('DROP TABLE "user"')
        cursor.execute('ALTER TABLE user_temp RENAME TO "user"')
        print("  ✅ Таблица user восстановлена с UUID id")
        
        # 3. Создаем таблицы токенов с UUID user_id
        print("\n🔧 Создание таблиц токенов с UUID user_id...")
        
        # refresh_token
        cursor.execute("""
            CREATE TABLE refresh_token (
                id SERIAL PRIMARY KEY,
                token VARCHAR(255) NOT NULL,
                user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
                expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица refresh_token создана")
        
        # reset_password_token
        cursor.execute("""
            CREATE TABLE reset_password_token (
                id SERIAL PRIMARY KEY,
                token VARCHAR(255) NOT NULL,
                user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
                expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            )
        """)
        print("  ✅ Таблица reset_password_token создана")
        
        # email_verification_code
        cursor.execute("""
            CREATE TABLE email_verification_code (
                code INTEGER NOT NULL,
                email VARCHAR(30) NOT NULL,
                optional_data JSON,
                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL,
                CONSTRAINT pk_email_verification_code PRIMARY KEY (code, email)
            )
        """)
        print("  ✅ Таблица email_verification_code создана")
        
        # 4. Создаем таблицы review с UUID user_id
        print("\n🔧 Создание таблиц review с UUID user_id...")
        
        # review
        cursor.execute("""
            CREATE TABLE review (
                id SERIAL PRIMARY KEY,
                rating INTEGER NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                quest_id INTEGER NOT NULL REFERENCES quest(id) ON DELETE CASCADE,
                text TEXT NOT NULL,
                owner_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
                user_id UUID REFERENCES "user"(id) ON DELETE CASCADE
            )
        """)
        print("  ✅ Таблица review создана")
        
        # review_response
        cursor.execute("""
            CREATE TABLE review_response (
                id SERIAL PRIMARY KEY,
                text TEXT NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                review_id INTEGER REFERENCES review(id) ON DELETE CASCADE,
                user_id UUID REFERENCES "user"(id) ON DELETE CASCADE
            )
        """)
        print("  ✅ Таблица review_response создана")
        
        # 5. Обновляем данные админа
        print("\n🔧 Обновление данных админа...")
        admin_password = hash_password("admin123")
        cursor.execute("""
            UPDATE "user" SET 
                password = %s,
                role = 'admin',
                is_verified = true,
                can_edit_quests = true,
                can_lock_users = true,
                first_name = 'Admin',
                last_name = 'User',
                full_name = 'Admin User'
            WHERE email = 'admin@questcity.com'
        """, (admin_password,))
        print("  ✅ Данные админа обновлены")
        
        # 6. Создаем таблицу alembic_version
        print("\n🔧 Создание таблицы alembic_version...")
        cursor.execute("""
            CREATE TABLE alembic_version (
                version_num VARCHAR(32) NOT NULL,
                CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
            )
        """)
        cursor.execute("INSERT INTO alembic_version (version_num) VALUES ('11cae1179d5e')")
        print("  ✅ Таблица alembic_version создана")
        
        cursor.close()
        conn.close()
        print("\n✅ Восстановление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    restore_correct_database_structure()
