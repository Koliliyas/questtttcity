#!/usr/bin/env python3
"""
Простое создание подтвержденного пользователя через SQL
"""
import asyncio
import sys
import bcrypt
from sqlalchemy import text
from db.dependencies import create_session

async def create_verified_user():
    """Создает пользователя с подтвержденным email через SQL"""
    
    # Данные пользователя
    username = "verified_user"
    email = "verified@test.com"  
    password = "VerifiedPass123!"
    
    print("🔧 Создание подтвержденного пользователя...")
    print(f"   Username: {username}")
    print(f"   Email: {email}")
    print(f"   Password: {password}")
    
    try:
        # Хешируем пароль
        password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        
        async with create_session() as session:
            # Сначала создаем профиль
            profile_result = await session.execute(text("""
                INSERT INTO profile (avatar_url, instagram_username, credits) 
                VALUES (NULL, '', 0) 
                RETURNING id
            """))
            profile_id = profile_result.scalar()
            
            print(f"✅ Профиль создан с ID: {profile_id}")
            
            # Проверяем существует ли пользователь
            check_result = await session.execute(text("""
                SELECT id FROM "user" WHERE username = :username OR email = :email
            """), {"username": username, "email": email})
            
            existing_user = check_result.first()
            
            if existing_user:
                print("⚠️  Пользователь уже существует, обновляем статус...")
                # Обновляем существующего пользователя
                await session.execute(text("""
                    UPDATE "user" 
                    SET is_verified = true, is_active = true, password = :password_hash
                    WHERE username = :username
                """), {"password_hash": password_hash, "username": username})
            else:
                # Создаем нового пользователя  
                print("📝 Создание нового пользователя...")
                await session.execute(text("""
                    INSERT INTO "user" (
                        id, username, first_name, last_name, password, email, 
                        profile_id, role, is_active, is_verified, can_edit_quests, can_lock_users,
                        created_at, updated_at
                    ) VALUES (
                        gen_random_uuid(), :username, 'Verified', 'User', :password_hash, :email,
                        :profile_id, 0, true, true, false, false,
                        NOW(), NOW()
                    )
                """), {
                    "username": username,
                    "password_hash": password_hash, 
                    "email": email,
                    "profile_id": profile_id
                })
            
            # Сохраняем изменения
            await session.commit()
            
            # Проверяем результат
            result = await session.execute(text("""
                SELECT u.username, u.email, u.is_verified, u.is_active, u.id
                FROM "user" u WHERE u.username = :username
            """), {"username": username})
            
            user = result.first()
            
            if user:
                print("✅ Пользователь создан и подтвержден:")
                print(f"   ID: {user.id}")
                print(f"   Username: {user.username}")
                print(f"   Email: {user.email}")
                print(f"   Verified: {user.is_verified}")
                print(f"   Active: {user.is_active}")
                return True
            else:
                print("❌ Пользователь не найден после создания")
                return False
                
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()
        return False

async def main():
    print("🚀 Создание подтвержденного пользователя для тестирования")
    print("=" * 60)
    
    success = await create_verified_user()
    
    if success:
        print("\n🎉 Успешно! Теперь можно тестировать авторизацию:")
        print("   Username: verified_user")
        print("   Password: VerifiedPass123!")
        print("\n🧪 Быстрый тест:")
        print("   curl -X POST http://localhost:8000/api/v1/auth/login \\")
        print("        -d 'login=verified_user&password=VerifiedPass123!'")
    else:
        print("\n❌ Не удалось создать пользователя")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main()) 