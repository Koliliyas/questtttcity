#!/usr/bin/env python3
"""
Проверяем как сохранились данные пользователя в базе
"""
import asyncio
from sqlalchemy import text
from db.dependencies import create_session

async def check_user_data():
    """Проверяет данные пользователя в базе"""
    
    username = "manual_test"
    
    try:
        async with create_session() as session:
            # Получаем данные пользователя
            result = await session.execute(text("""
                SELECT 
                    u.id,
                    u.username, 
                    u.email, 
                    u.first_name,
                    u.last_name,
                    u.password,
                    u.is_verified, 
                    u.is_active,
                    u.role,
                    u.created_at,
                    p.id as profile_id,
                    p.credits
                FROM "user" u
                JOIN profile p ON u.profile_id = p.id
                WHERE u.username = :username
            """), {"username": username})
            
            user = result.first()
            
            if user:
                print("👤 ДАННЫЕ ПОЛЬЗОВАТЕЛЯ:")
                print(f"   ID: {user.id}")
                print(f"   Username: {user.username}")
                print(f"   Email: {user.email}")
                print(f"   Full Name: {user.first_name} {user.last_name}")
                print(f"   Created: {user.created_at}")
                print("")
                print("🔐 СТАТУСЫ:")
                print(f"   Verified: {user.is_verified}")
                print(f"   Active: {user.is_active}")
                print(f"   Role: {user.role}")
                print("")
                print("🗝️ ПАРОЛЬ:")
                print(f"   Hash Length: {len(user.password)} characters")
                print(f"   Hash Type: {type(user.password)}")
                print(f"   Hash Preview: {user.password[:50]}...")
                print(f"   Starts with $2b$: {user.password.startswith('$2b$')}")
                print("")
                print("👤 ПРОФИЛЬ:")
                print(f"   Profile ID: {user.profile_id}")
                print(f"   Credits: {user.credits}")
                
                return user
            else:
                print("❌ Пользователь не найден")
                return None
                
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()
        return None

async def main():
    print("🔍 Проверка данных пользователя manual_test")
    print("=" * 50)
    
    user = await check_user_data()
    
    if user:
        print("\n✅ Данные получены успешно!")
        print("\n📋 Следующий шаг: ручная верификация email")
    else:
        print("\n❌ Не удалось получить данные пользователя")

if __name__ == "__main__":
    asyncio.run(main()) 