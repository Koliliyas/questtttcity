"""
Улучшенная система structured logging для QuestCity Backend.

Использует structlog для создания структурированных логов с JSON форматом,
correlation IDs, контекстной информацией и метаданными для мониторинга.
"""

import logging
import logging.config
import sys
from typing import Any, Dict, Optional

import structlog
from pythonjsonlogger import json


def add_correlation_id(logger, method_name, event_dict):
    """Добавляет correlation ID к логам для трассировки запросов."""
    # Получаем correlation ID из контекста (например, из FastAPI middleware)
    import contextvars
    
    correlation_id = getattr(contextvars, 'correlation_id', None)
    if correlation_id and hasattr(correlation_id, 'get'):
        try:
            event_dict['correlation_id'] = correlation_id.get()
        except LookupError:
            pass  # Если correlation_id не установлен
    
    return event_dict


def add_service_metadata(logger, method_name, event_dict):
    """Добавляет метаданные сервиса к логам."""
    event_dict.update({
        'service': 'questcity-backend',
        'version': '1.0.0',  # TODO: Получать из settings или переменных окружения
        'environment': 'production',  # TODO: Получать из settings
    })
    return event_dict


def filter_sensitive_data(logger, method_name, event_dict):
    """Фильтрует чувствительные данные из логов."""
    sensitive_keys = {'password', 'token', 'secret', 'key', 'authorization'}
    
    def clean_dict(d):
        if isinstance(d, dict):
            return {
                k: '***REDACTED***' if any(sensitive in k.lower() for sensitive in sensitive_keys)
                else clean_dict(v) for k, v in d.items()
            }
        elif isinstance(d, (list, tuple)):
            return [clean_dict(item) for item in d]
        return d
    
    return clean_dict(event_dict)


# Настройка structlog
structlog.configure(
    processors=[
        # Добавляем метаданные и безопасность
        add_service_metadata,
        add_correlation_id,
        filter_sensitive_data,
        
        # Стандартные процессоры structlog
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        
        # JSON сериализация для production
        structlog.processors.JSONRenderer(sort_keys=True)
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
    logger_factory=structlog.WriteLoggerFactory(),
    cache_logger_on_first_use=True,
)


# Настройка стандартного logging для совместимости
class StructlogHandler(logging.Handler):
    """Handler для перенаправления стандартных логов в structlog."""
    
    def __init__(self):
        super().__init__()
        self.logger = structlog.get_logger()
    
    def emit(self, record):
        """Перенаправляем стандартные логи в structlog."""
        try:
            # Конвертируем LogRecord в structlog format
            log_entry = {
                'logger_name': record.name,
                'level': record.levelname,
                'message': record.getMessage(),
                'module': record.module,
                'function': record.funcName,
                'line': record.lineno,
            }
            
            # Добавляем exception info если есть
            if record.exc_info:
                log_entry['exc_info'] = self.format(record)
            
            # Отправляем в structlog
            if record.levelno >= logging.ERROR:
                self.logger.error("Legacy log", **log_entry)
            elif record.levelno >= logging.WARNING:
                self.logger.warning("Legacy log", **log_entry)
            elif record.levelno >= logging.INFO:
                self.logger.info("Legacy log", **log_entry)
            else:
                self.logger.debug("Legacy log", **log_entry)
                
        except Exception:
            self.handleError(record)


# Настройка корневого logger для перехвата всех логов
root_logger = logging.getLogger()
root_logger.handlers.clear()  # Удаляем существующие handlers
root_logger.addHandler(StructlogHandler())
root_logger.setLevel(logging.INFO)

# Создаем основной logger для приложения
logger = structlog.get_logger("questcity.backend")


def get_logger(name: Optional[str] = None) -> structlog.BoundLogger:
    """
    Получение logger'а с поддержкой structured logging.
    
    Args:
        name: Имя logger'а. Если не указано, используется основной logger.
        
    Returns:
        Structlog logger с настроенными процессорами.
        
    Example:
        >>> log = get_logger("questcity.auth")
        >>> log.info("User login", user_id=123, ip="192.168.1.1")
        >>> log.error("Authentication failed", 
        ...           user_id=123, 
        ...           reason="invalid_password",
        ...           attempts=3)
    """
    if name:
        return structlog.get_logger(name)
    return logger


def setup_logging_for_environment(environment: str = "production"):
    """
    Настройка логирования в зависимости от среды.
    
    Args:
        environment: Среда выполнения ("development", "production", "testing")
    """
    if environment == "development":
        # В development добавляем консольный вывод с цветами
        structlog.configure(
            processors=[
                add_service_metadata,
                add_correlation_id,
                filter_sensitive_data,
                structlog.contextvars.merge_contextvars,
                structlog.processors.add_log_level,
                structlog.processors.add_logger_name,
                structlog.processors.TimeStamper(fmt="iso"),
                structlog.dev.ConsoleRenderer(colors=True)  # Красивый вывод для разработки
            ],
            wrapper_class=structlog.make_filtering_bound_logger(logging.DEBUG),
            logger_factory=structlog.WriteLoggerFactory(),
            cache_logger_on_first_use=True,
        )
        root_logger.setLevel(logging.DEBUG)
    elif environment == "testing":
        # В тестах минимальное логирование
        root_logger.setLevel(logging.WARNING)


# Утилитарные функции для специальных типов логов

def log_api_request(endpoint: str, method: str, user_id: Optional[int] = None, **kwargs):
    """Логирование API запросов."""
    logger.info(
        "API request",
        event="api_request",
        endpoint=endpoint,
        method=method,
        user_id=user_id,
        **kwargs
    )


def log_api_response(endpoint: str, status_code: int, duration_ms: float, **kwargs):
    """Логирование API ответов."""
    logger.info(
        "API response",
        event="api_response", 
        endpoint=endpoint,
        status_code=status_code,
        duration_ms=duration_ms,
        **kwargs
    )


def log_database_query(query_type: str, table: str, duration_ms: float, **kwargs):
    """Логирование запросов к базе данных."""
    logger.debug(
        "Database query",
        event="database_query",
        query_type=query_type,
        table=table,
        duration_ms=duration_ms,
        **kwargs
    )


def log_security_event(event_type: str, severity: str = "info", **kwargs):
    """Логирование событий безопасности."""
    log_func = getattr(logger, severity.lower(), logger.info)
    log_func(
        "Security event",
        event="security_event",
        event_type=event_type,
        **kwargs
    )


def log_business_event(event_type: str, **kwargs):
    """Логирование бизнес-событий."""
    logger.info(
        "Business event",
        event="business_event",
        event_type=event_type,
        **kwargs
    )


# Экспорт главного logger'а для обратной совместимости
__all__ = [
    'logger', 
    'get_logger', 
    'setup_logging_for_environment',
    'log_api_request',
    'log_api_response', 
    'log_database_query',
    'log_security_event',
    'log_business_event'
]
