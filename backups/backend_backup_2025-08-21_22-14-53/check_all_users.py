#!/usr/bin/env python3
"""
Проверяем всех пользователей в базе данных
"""
import asyncio
from sqlalchemy import text
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent / "src"))
from db.dependencies import create_session

async def check_all_users():
    """Проверяет всех пользователей в базе"""
    
    try:
        async with create_session() as session:
            # Получаем всех пользователей
            result = await session.execute(text("""
                SELECT 
                    u.id,
                    u.username, 
                    u.email, 
                    u.is_verified, 
                    u.is_active,
                    u.created_at
                FROM "user" u
                ORDER BY u.created_at DESC
                LIMIT 10
            """))
            
            users = result.fetchall()
            
            if users:
                print(f"👥 НАЙДЕНО ПОЛЬЗОВАТЕЛЕЙ: {len(users)}")
                print("=" * 80)
                
                for i, user in enumerate(users, 1):
                    print(f"{i}. {user.username} ({user.email})")
                    print(f"   ID: {user.id}")
                    print(f"   Verified: {user.is_verified} | Active: {user.is_active}")
                    print(f"   Created: {user.created_at}")
                    print("-" * 40)
                
                return users
            else:
                print("❌ Пользователи не найдены в базе данных")
                return []
                
    except Exception as e:
        print(f"❌ Ошибка подключения к базе: {e}")
        import traceback
        traceback.print_exc()
        return []

async def check_email_codes():
    """Проверяет коды верификации email"""
    try:
        async with create_session() as session:
            result = await session.execute(text("""
                SELECT 
                    email,
                    code,
                    created_at,
                    expire_at
                FROM email_verification_code
                ORDER BY created_at DESC
                LIMIT 5
            """))
            
            codes = result.fetchall()
            
            if codes:
                print("\n📧 EMAIL VERIFICATION CODES:")
                print("=" * 50)
                for code in codes:
                    print(f"Email: {code.email}")
                    print(f"Code: {code.code}")
                    print(f"Created: {code.created_at}")
                    print(f"Expires: {code.expire_at}")
                    print("-" * 30)
            else:
                print("\n📧 Email verification codes не найдены")
                
    except Exception as e:
        print(f"❌ Ошибка получения email codes: {e}")

async def main():
    print("🔍 Проверка всех пользователей в базе данных")
    print("=" * 60)
    
    users = await check_all_users()
    await check_email_codes()
    
    if users:
        print(f"\n✅ База данных содержит {len(users)} пользователей")
    else:
        print("\n⚠️ База данных пуста или недоступна")

if __name__ == "__main__":
    asyncio.run(main()) 