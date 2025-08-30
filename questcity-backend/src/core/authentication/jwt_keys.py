"""
QuestCity Backend - JWT Keys Management

Модуль для безопасного управления JWT ключами:
- Автоматическая генерация RSA ключей
- Проверка существования ключей
- Безопасные права доступа к файлам
- Валидация ключей
"""

import logging
import os
import stat
from pathlib import Path
from typing import Tuple

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa

logger = logging.getLogger(__name__)


class JWTKeysError(Exception):
    """Исключение при работе с JWT ключами"""
    pass


def generate_rsa_keypair(key_size: int = 2048) -> Tuple[str, str]:
    """
    Генерирует пару RSA ключей (приватный и публичный).
    
    Args:
        key_size: Размер ключа в битах (минимум 2048 для безопасности)
        
    Returns:
        Tuple[str, str]: (private_key_pem, public_key_pem)
        
    Raises:
        JWTKeysError: При ошибке генерации ключей
    """
    if key_size < 2048:
        raise JWTKeysError("Размер ключа должен быть минимум 2048 бит для безопасности")
    
    try:
        # Генерируем приватный ключ
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=key_size,
        )
        
        # Сериализуем приватный ключ в PEM формат
        private_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ).decode('utf-8')
        
        # Получаем публичный ключ
        public_key = private_key.public_key()
        
        # Сериализуем публичный ключ в PEM формат
        public_pem = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        ).decode('utf-8')
        
        logger.info(f"Сгенерирована RSA пара ключей {key_size} бит")
        return private_pem, public_pem
        
    except Exception as e:
        raise JWTKeysError(f"Ошибка генерации RSA ключей: {e}")


def set_file_permissions(file_path: Path, is_private: bool = False) -> None:
    """
    Устанавливает безопасные права доступа к файлу ключа.
    
    Args:
        file_path: Путь к файлу ключа
        is_private: True для приватного ключа (только владелец), False для публичного
    """
    try:
        if is_private:
            # Приватный ключ: только владелец может читать/писать (600)
            file_path.chmod(stat.S_IRUSR | stat.S_IWUSR)
            logger.debug(f"Установлены права 600 для {file_path}")
        else:
            # Публичный ключ: владелец и группа могут читать (644)
            file_path.chmod(stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH)
            logger.debug(f"Установлены права 644 для {file_path}")
    except Exception as e:
        logger.warning(f"Не удалось установить права доступа для {file_path}: {e}")


def create_certs_directory(certs_dir: Path) -> None:
    """
    Создает директорию для сертификатов с безопасными правами доступа.
    
    Args:
        certs_dir: Путь к директории certs
        
    Raises:
        JWTKeysError: При ошибке создания директории
    """
    try:
        if not certs_dir.exists():
            certs_dir.mkdir(parents=True, exist_ok=True)
            # Устанавливаем права 755 (владелец: rwx, группа и другие: r-x)
            certs_dir.chmod(stat.S_IRWXU | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH)
            logger.info(f"Создана директория для ключей: {certs_dir}")
        else:
            logger.debug(f"Директория ключей уже существует: {certs_dir}")
    except Exception as e:
        raise JWTKeysError(f"Ошибка создания директории {certs_dir}: {e}")


def validate_rsa_key(key_content: str, is_private: bool = True) -> bool:
    """
    Валидирует RSA ключ.
    
    Args:
        key_content: Содержимое ключа в PEM формате
        is_private: True для приватного ключа, False для публичного
        
    Returns:
        bool: True если ключ валиден
    """
    try:
        key_bytes = key_content.encode('utf-8')
        
        if is_private:
            serialization.load_pem_private_key(key_bytes, password=None)
        else:
            serialization.load_pem_public_key(key_bytes)
        
        return True
    except Exception as e:
        logger.error(f"Невалидный {'приватный' if is_private else 'публичный'} ключ: {e}")
        return False


def save_key_to_file(key_content: str, file_path: Path, is_private: bool = True) -> None:
    """
    Сохраняет ключ в файл с безопасными правами доступа.
    
    Args:
        key_content: Содержимое ключа в PEM формате
        file_path: Путь к файлу для сохранения
        is_private: True для приватного ключа, False для публичного
        
    Raises:
        JWTKeysError: При ошибке сохранения
    """
    try:
        # Валидируем ключ перед сохранением
        if not validate_rsa_key(key_content, is_private):
            raise JWTKeysError(f"Невалидный {'приватный' if is_private else 'публичный'} ключ")
        
        # Создаем директорию если не существует
        create_certs_directory(file_path.parent)
        
        # Сохраняем ключ
        file_path.write_text(key_content, encoding='utf-8')
        
        # Устанавливаем безопасные права доступа
        set_file_permissions(file_path, is_private)
        
        logger.info(f"Сохранен {'приватный' if is_private else 'публичный'} ключ: {file_path}")
        
    except Exception as e:
        raise JWTKeysError(f"Ошибка сохранения ключа в {file_path}: {e}")


def ensure_jwt_keys_exist(private_key_path: Path, public_key_path: Path, key_size: int = 2048) -> None:
    """
    Проверяет существование JWT ключей и создает их при необходимости.
    
    Args:
        private_key_path: Путь к приватному ключу
        public_key_path: Путь к публичному ключу
        key_size: Размер ключа в битах
        
    Raises:
        JWTKeysError: При ошибке создания или валидации ключей
    """
    logger.info("Проверка JWT ключей...")
    
    # Проверяем существование файлов
    private_exists = private_key_path.exists()
    public_exists = public_key_path.exists()
    
    # Если оба ключа существуют, валидируем их
    if private_exists and public_exists:
        try:
            private_content = private_key_path.read_text(encoding='utf-8')
            public_content = public_key_path.read_text(encoding='utf-8')
            
            if validate_rsa_key(private_content, True) and validate_rsa_key(public_content, False):
                logger.info("JWT ключи существуют и валидны")
                
                # Проверяем права доступа и исправляем при необходимости
                set_file_permissions(private_key_path, True)
                set_file_permissions(public_key_path, False)
                return
            else:
                logger.warning("Существующие JWT ключи невалидны, генерируем новые")
        except Exception as e:
            logger.warning(f"Ошибка чтения существующих ключей: {e}, генерируем новые")
    
    # Если ключи отсутствуют или невалидны, генерируем новые
    elif private_exists != public_exists:
        logger.warning("Найден только один ключ из пары, генерируем новую пару")
    else:
        logger.info("JWT ключи отсутствуют, генерируем новую пару")
    
    try:
        # Генерируем новую пару ключей
        private_pem, public_pem = generate_rsa_keypair(key_size)
        
        # Сохраняем ключи
        save_key_to_file(private_pem, private_key_path, True)
        save_key_to_file(public_pem, public_key_path, False)
        
        logger.info("✅ JWT ключи успешно созданы и сохранены")
        
    except Exception as e:
        raise JWTKeysError(f"Ошибка создания JWT ключей: {e}")


def load_and_validate_key(key_path: Path, is_private: bool = True) -> str:
    """
    Загружает и валидирует ключ из файла.
    
    Args:
        key_path: Путь к файлу ключа
        is_private: True для приватного ключа, False для публичного
        
    Returns:
        str: Содержимое ключа
        
    Raises:
        JWTKeysError: При ошибке загрузки или валидации
    """
    try:
        if not key_path.exists():
            raise JWTKeysError(f"Файл ключа не найден: {key_path}")
        
        key_content = key_path.read_text(encoding='utf-8')
        
        if not validate_rsa_key(key_content, is_private):
            raise JWTKeysError(f"Невалидный ключ в файле: {key_path}")
        
        return key_content
        
    except Exception as e:
        raise JWTKeysError(f"Ошибка загрузки ключа из {key_path}: {e}")


def get_key_info(key_path: Path) -> dict:
    """
    Получает информацию о ключе.
    
    Args:
        key_path: Путь к файлу ключа
        
    Returns:
        dict: Информация о ключе
    """
    try:
        if not key_path.exists():
            return {"exists": False}
        
        stat_info = key_path.stat()
        permissions = oct(stat_info.st_mode)[-3:]
        
        # Проверяем валидность ключа
        content = key_path.read_text(encoding='utf-8')
        is_private = "PRIVATE KEY" in content
        is_valid = validate_rsa_key(content, is_private)
        
        return {
            "exists": True,
            "path": str(key_path),
            "size": stat_info.st_size,
            "permissions": permissions,
            "is_private": is_private,
            "is_valid": is_valid,
            "modified": stat_info.st_mtime
        }
    except Exception as e:
        return {
            "exists": True,
            "error": str(e)
        } 