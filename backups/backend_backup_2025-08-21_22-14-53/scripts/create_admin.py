#!/usr/bin/env python3
"""
QuestCity Backend - Admin User Creation Script

Создает базового администратора при развертывании системы.
Поддерживает безопасную настройку через переменные окружения и CLI аргументы.

Usage:
    python scripts/create_admin.py
    python scripts/create_admin.py --username admin --email admin@questcity.com
    python scripts/create_admin.py --interactive
"""

import asyncio
import getpass
import logging
import os
import secrets
import string
import sys
from argparse import ArgumentParser
from pathlib import Path
from typing import Optional

import dotenv
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

# Добавляем src в путь для импортов
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from core.authentication.utils import hash_password
from db.engine import async_session_factory
from db.models.user import Profile, User

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger("create_admin")

# Загружаем переменные окружения
dotenv.load_dotenv()


class AdminCreationError(Exception):
    """Исключение при создании администратора"""
    pass


def generate_secure_password(length: int = 16) -> str:
    """Генерирует безопасный пароль с символами разных типов"""
    if length < 8:
        raise ValueError("Пароль должен быть минимум 8 символов")
    
    # Обеспечиваем наличие разных типов символов
    lowercase = string.ascii_lowercase
    uppercase = string.ascii_uppercase
    digits = string.digits
    special = "!@#$%^&*()-_=+"
    
    # Минимум по одному символу каждого типа
    password = [
        secrets.choice(lowercase),
        secrets.choice(uppercase),
        secrets.choice(digits),
        secrets.choice(special)
    ]
    
    # Заполняем остальные символы случайно
    all_chars = lowercase + uppercase + digits + special
    for _ in range(length - 4):
        password.append(secrets.choice(all_chars))
    
    # Перемешиваем символы
    secrets.SystemRandom().shuffle(password)
    return ''.join(password)


def validate_email(email: str) -> bool:
    """Простая валидация email"""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


def validate_username(username: str) -> bool:
    """Валидация username (3-15 символов, только буквы, цифры, подчеркивание)"""
    import re
    if len(username) < 3 or len(username) > 15:
        return False
    pattern = r'^[a-zA-Z0-9_]+$'
    return re.match(pattern, username) is not None


async def check_admin_exists() -> tuple[bool, Optional[User]]:
    """Проверяет существование администратора в системе"""
    async with async_session_factory() as session:
        # Ищем пользователей с админскими правами
        stmt = select(User).where(
            (User.role >= 2) | 
            (User.can_edit_quests == True) | 
            (User.can_lock_users == True)
        )
        result = await session.execute(stmt)
        admin = result.scalar_one_or_none()
        return admin is not None, admin


async def create_admin_user(
    username: str,
    email: str, 
    password: str,
    first_name: str,
    last_name: str,
    instagram_username: str = "",
    initial_credits: int = 1000
) -> User:
    """Создает администратора в базе данных"""
    
    logger.info(f"Создание администратора: {username} ({email})")
    
    # Валидация входных данных
    if not validate_username(username):
        raise AdminCreationError(f"Некорректное имя пользователя: {username}")
    
    if not validate_email(email):
        raise AdminCreationError(f"Некорректный email: {email}")
    
    if len(password) < 8:
        raise AdminCreationError("Пароль должен быть минимум 8 символов")
    
    try:
        async with async_session_factory.begin() as session:
            # Проверяем что пользователь не существует
            existing_user_stmt = select(User).where(
                (User.username == username) | (User.email == email)
            )
            existing_result = await session.execute(existing_user_stmt)
            existing_user = existing_result.scalar_one_or_none()
            
            if existing_user:
                if existing_user.username == username:
                    raise AdminCreationError(f"Пользователь с именем '{username}' уже существует")
                else:
                    raise AdminCreationError(f"Пользователь с email '{email}' уже существует")
            
            # Создаем профиль
            profile = Profile(
                avatar_url=None,
                instagram_username=instagram_username,
                credits=initial_credits
            )
            session.add(profile)
            await session.flush()  # Получаем ID профиля
            
            # Хешируем пароль
            hashed_password = str(hash_password(password))
            
            # Создаем администратора
            admin = User(
                username=username,
                first_name=first_name,
                last_name=last_name,
                password=hashed_password,
                email=email,
                profile_id=profile.id,
                role=2,  # Роль администратора
                is_active=True,
                is_verified=True,
                can_edit_quests=True,
                can_lock_users=True
            )
            session.add(admin)
            
            logger.info(f"Администратор '{username}' успешно создан")
            return admin
            
    except IntegrityError as e:
        raise AdminCreationError(f"Ошибка целостности данных: {e}")
    except Exception as e:
        raise AdminCreationError(f"Ошибка создания администратора: {e}")


def get_admin_config_from_env() -> dict:
    """Получает конфигурацию администратора из переменных окружения"""
    return {
        'username': os.getenv('ADMIN_USERNAME', 'admin'),
        'email': os.getenv('ADMIN_EMAIL', 'admin@questcity.com'),
        'password': os.getenv('ADMIN_PASSWORD'),
        'first_name': os.getenv('ADMIN_FIRST_NAME', 'System'),
        'last_name': os.getenv('ADMIN_LAST_NAME', 'Administrator'),
        'instagram_username': os.getenv('ADMIN_INSTAGRAM', ''),
        'initial_credits': int(os.getenv('ADMIN_INITIAL_CREDITS', '1000'))
    }


def get_admin_config_interactive() -> dict:
    """Интерактивная настройка администратора"""
    print("\n=== Создание администратора QuestCity ===")
    print("Введите данные для нового администратора:\n")
    
    # Username
    while True:
        username = input("Username (3-15 символов, буквы, цифры, _): ").strip()
        if validate_username(username):
            break
        print("❌ Некорректный username. Попробуйте еще раз.")
    
    # Email
    while True:
        email = input("Email: ").strip()
        if validate_email(email):
            break
        print("❌ Некорректный email. Попробуйте еще раз.")
    
    # Password
    while True:
        password = getpass.getpass("Пароль (минимум 8 символов): ").strip()
        if len(password) >= 8:
            password_confirm = getpass.getpass("Подтвердите пароль: ").strip()
            if password == password_confirm:
                break
            print("❌ Пароли не совпадают. Попробуйте еще раз.")
        else:
            print("❌ Пароль слишком короткий. Минимум 8 символов.")
    
    # Имя и фамилия
    first_name = input("Имя [System]: ").strip() or "System"
    last_name = input("Фамилия [Administrator]: ").strip() or "Administrator"
    
    # Instagram (опционально)
    instagram_username = input("Instagram username (опционально): ").strip()
    
    # Кредиты
    while True:
        credits_input = input("Начальные кредиты [1000]: ").strip()
        if not credits_input:
            initial_credits = 1000
            break
        try:
            initial_credits = int(credits_input)
            if initial_credits >= 0:
                break
            print("❌ Количество кредитов должно быть >= 0")
        except ValueError:
            print("❌ Введите корректное число")
    
    return {
        'username': username,
        'email': email,
        'password': password,
        'first_name': first_name,
        'last_name': last_name,
        'instagram_username': instagram_username,
        'initial_credits': initial_credits
    }


async def main():
    """Главная функция"""
    parser = ArgumentParser(description="Создание администратора QuestCity")
    parser.add_argument('--username', help='Имя пользователя администратора')
    parser.add_argument('--email', help='Email администратора')
    parser.add_argument('--password', help='Пароль (не рекомендуется использовать в CLI)')
    parser.add_argument('--first-name', help='Имя администратора')
    parser.add_argument('--last-name', help='Фамилия администратора')
    parser.add_argument('--instagram', help='Instagram username')
    parser.add_argument('--credits', type=int, help='Начальные кредиты')
    parser.add_argument('--interactive', '-i', action='store_true', 
                       help='Интерактивный режим настройки')
    parser.add_argument('--force', action='store_true',
                       help='Принудительное создание (пропустить проверку существования)')
    parser.add_argument('--generate-password', action='store_true',
                       help='Автоматически сгенерировать безопасный пароль')
    
    args = parser.parse_args()
    
    try:
        # Проверяем существование администратора
        if not args.force:
            admin_exists, existing_admin = await check_admin_exists()
            if admin_exists:
                logger.warning(f"Администратор уже существует: {existing_admin.username} ({existing_admin.email})")
                if not input("Продолжить создание нового администратора? (y/N): ").lower().startswith('y'):
                    logger.info("Создание администратора отменено")
                    return
        
        # Получаем конфигурацию
        if args.interactive:
            config = get_admin_config_interactive()
        else:
            # Сначала из переменных окружения
            config = get_admin_config_from_env()
            
            # Затем переопределяем из CLI аргументов
            if args.username:
                config['username'] = args.username
            if args.email:
                config['email'] = args.email
            if args.password:
                config['password'] = args.password
            if args.first_name:
                config['first_name'] = args.first_name
            if args.last_name:
                config['last_name'] = args.last_name
            if args.instagram:
                config['instagram_username'] = args.instagram
            if args.credits is not None:
                config['initial_credits'] = args.credits
        
        # Обработка пароля
        if not config['password']:
            if args.generate_password:
                config['password'] = generate_secure_password()
                logger.info("Сгенерирован автоматический пароль")
            else:
                config['password'] = getpass.getpass("Введите пароль администратора: ")
        
        # Создаем администратора
        admin = await create_admin_user(**config)
        
        print(f"\n✅ Администратор успешно создан!")
        print(f"   Username: {admin.username}")
        print(f"   Email: {admin.email}")
        print(f"   Полное имя: {admin.full_name}")
        print(f"   ID: {admin.id}")
        
        if args.generate_password:
            print(f"\n🔑 Сгенерированный пароль: {config['password']}")
            print("⚠️  ВНИМАНИЕ: Сохраните этот пароль в безопасном месте!")
        
        logger.info("Администратор готов к использованию")
        
    except AdminCreationError as e:
        logger.error(f"Ошибка создания администратора: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        logger.info("Создание администратора прервано пользователем")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Неожиданная ошибка: {e}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main()) 