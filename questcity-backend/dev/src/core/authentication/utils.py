import random
import secrets

import bcrypt


def hash_password(password: str) -> bytes:
    salt = bcrypt.gensalt()
    pwd_bytes = password.encode()
    return bcrypt.hashpw(pwd_bytes, salt)


# TODO: refactor hashed_password=hashed_password[2: -1].encode()


def validate_password(password: str, hashed_password: bytes) -> bool:
    return bcrypt.checkpw(
        password=password.encode(), hashed_password=hashed_password[2:-1].encode()
    )


def get_random_refresh_token():
    return get_random_token()


def get_random_token():
    return secrets.token_urlsafe(32)


def get_random_verification_code():
    return random.randint(100000, 999999)
