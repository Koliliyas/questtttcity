import random
import secrets

import bcrypt


def hash_password(password: str) -> bytes:
    salt = bcrypt.gensalt()
    pwd_bytes = password.encode()
    return bcrypt.hashpw(pwd_bytes, salt)


# TODO: refactor hashed_password=hashed_password[2: -1].encode()


def validate_password(password: str, hashed_password: str | bytes) -> bool:
    """Проверяет пароль, поддерживает как string так и bytes хеши"""
    # Конвертируем string в bytes если нужно
    if isinstance(hashed_password, str):
        hashed_password = hashed_password.encode('utf-8')
    
    return bcrypt.checkpw(
        password=password.encode(), 
        hashed_password=hashed_password
    )


def get_random_refresh_token() -> str:
    return get_random_token()


def get_random_token() -> str:
    return secrets.token_urlsafe(32)


def get_random_verification_code() -> int:
    return random.randint(100000, 999999)
