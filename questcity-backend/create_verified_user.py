#!/usr/bin/env python3
"""
Создание подтвержденного пользователя для тестирования
"""
import asyncio
import sys
from sqlalchemy import select, update
from core.user.services import UserService
from core.user.dto import UserCreateDTO, ProfileCreateDTO
from db.dependencies import create_session
from db.models.user import User
from core.di.container import create_container

async def create_verified_user():
    """Создает пользователя с подтвержденным email"""
    
    # Данные пользователя
    username = "verified_user"
    email = "verified@test.com"
    password = "VerifiedPass123!"
    
    print("🔧 Создание подтвержденного пользователя...")
    print(f"   Username: {username}")
    print(f"   Email: {email}")
    print(f"   Password: {password}")
    
    try:
        # Создаем контейнер зависимостей
        async with create_container() as container:
            # Получаем сервисы
            user_service = await container.get(UserService)
            
            # Создаем пользователя
            user_dto = UserCreateDTO(
                username=username,
                password=password,
                email=email,
                first_name="Verified",
                last_name="User"
            )
            
            profile_dto = ProfileCreateDTO(avatar_url=None)
            
            print("📝 Регистрация пользователя...")
            result = await user_service.register_user(
                user_dto=user_dto, 
                profile_dto=profile_dto
            )
            
            if result.is_err():
                error = result.err_value
                if "already exists" in str(error).lower():
                    print("⚠️  Пользователь уже существует, обновляем статус верификации...")
                else:
                    print(f"❌ Ошибка регистрации: {error}")
                    return False
            else:
                print("✅ Пользователь зарегистрирован")
            
            # Получаем сессию БД для прямого обновления
            async with create_session() as session:
                # Устанавливаем is_verified = True напрямую в БД
                print("🔐 Подтверждение email...")
                await session.execute(
                    update(User)
                    .where(User.username == username)
                    .values(is_verified=True, is_active=True)
                )
                await session.commit()
                
                # Проверяем результат
                result = await session.execute(
                    select(User.username, User.email, User.is_verified, User.is_active)
                    .where(User.username == username)
                )
                user = result.first()
            
            if user:
                print("✅ Пользователь создан и подтвержден:")
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
        print("\n🧪 Тест:")
        print("   curl -X POST http://localhost:8000/api/v1/auth/login \\")
        print("        -d 'login=verified_user&password=VerifiedPass123!'")
    else:
        print("\n❌ Не удалось создать пользователя")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main()) 