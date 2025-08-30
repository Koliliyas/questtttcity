# Exception handlers package

# Core exceptions (moved from core.exceptions.py to avoid import conflicts)
class PermissionDeniedError(Exception):
    """Исключение при отказе в доступе к ресурсу"""
    pass


class S3ServiceClientException(Exception):
    """Исключение при ошибках работы с S3 сервисом"""
    pass


# Экспорт обработчиков исключений
from .handlers import (
    http_exception_handler,
    file_validation_exception_handler,
    file_validation_mapper
)

__all__ = [
    # Core exceptions
    "PermissionDeniedError",
    "S3ServiceClientException",
    
    # Exception handlers
    "http_exception_handler", 
    "file_validation_exception_handler",
    "file_validation_mapper"
] 