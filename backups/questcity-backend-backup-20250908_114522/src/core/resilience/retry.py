"""
QuestCity Backend - Retry Mechanisms

Универсальные retry механизмы с:
- Экспоненциальной задержкой (exponential backoff)
- Jitter для распределения нагрузки
- Настраиваемые исключения для retry
- Логирование попыток
- Timeout защита
"""

import asyncio
import logging
import random
import time
from dataclasses import dataclass
from functools import wraps
from typing import Any, Callable, Optional, Set, Type, Union

logger = logging.getLogger(__name__)


@dataclass
class RetryConfig:
    """Конфигурация retry механизма"""
    
    max_attempts: int = 3
    base_delay: float = 1.0  # Базовая задержка в секундах
    max_delay: float = 60.0  # Максимальная задержка
    backoff_factor: float = 2.0  # Множитель для экспоненциальной задержки
    jitter: bool = True  # Добавлять случайную составляющую
    timeout: Optional[float] = None  # Общий timeout для всех попыток
    
    # Исключения для retry
    retry_exceptions: Set[Type[Exception]] = None
    ignore_exceptions: Set[Type[Exception]] = None
    
    def __post_init__(self):
        if self.retry_exceptions is None:
            # По умолчанию retry для сетевых и временных ошибок
            self.retry_exceptions = {
                ConnectionError,
                OSError,
                TimeoutError,
                asyncio.TimeoutError,
            }
        
        if self.ignore_exceptions is None:
            # Исключения которые нельзя retry (логические ошибки)
            self.ignore_exceptions = {
                ValueError,
                TypeError,
                AttributeError,
                KeyError,
                IndexError,
            }


class RetryExhaustedError(Exception):
    """Исключение когда все попытки retry исчерпаны"""
    
    def __init__(self, attempts: int, last_exception: Exception):
        self.attempts = attempts
        self.last_exception = last_exception
        super().__init__(
            f"Retry exhausted after {attempts} attempts. "
            f"Last error: {type(last_exception).__name__}: {last_exception}"
        )


def calculate_delay(attempt: int, config: RetryConfig) -> float:
    """
    Вычисляет задержку для указанной попытки.
    
    Args:
        attempt: Номер попытки (начиная с 0)
        config: Конфигурация retry
        
    Returns:
        float: Задержка в секундах
    """
    # Экспоненциальная задержка
    delay = config.base_delay * (config.backoff_factor ** attempt)
    
    # Ограничиваем максимальной задержкой
    delay = min(delay, config.max_delay)
    
    # Добавляем jitter если включен
    if config.jitter and delay > 0:
        # Jitter ±25% от базовой задержки
        jitter_amount = delay * 0.25
        delay += random.uniform(-jitter_amount, jitter_amount)
        delay = max(0, delay)  # Задержка не может быть отрицательной
    
    return delay


def should_retry(exception: Exception, config: RetryConfig) -> bool:
    """
    Определяет нужно ли повторить операцию при данном исключении.
    
    Args:
        exception: Возникшее исключение
        config: Конфигурация retry
        
    Returns:
        bool: True если нужно повторить
    """
    exception_type = type(exception)
    
    # Сначала проверяем игнорируемые исключения
    if any(issubclass(exception_type, ignore_type) 
           for ignore_type in config.ignore_exceptions):
        return False
    
    # Затем проверяем retry исключения
    return any(issubclass(exception_type, retry_type) 
               for retry_type in config.retry_exceptions)


async def async_retry(
    func: Callable,
    *args,
    config: Optional[RetryConfig] = None,
    **kwargs
) -> Any:
    """
    Асинхронный retry wrapper для функции.
    
    Args:
        func: Асинхронная функция для выполнения
        *args: Позиционные аргументы функции
        config: Конфигурация retry
        **kwargs: Именованные аргументы функции
        
    Returns:
        Any: Результат выполнения функции
        
    Raises:
        RetryExhaustedError: Если все попытки исчерпаны
    """
    if config is None:
        config = RetryConfig()
    
    start_time = time.time()
    last_exception = None
    
    for attempt in range(config.max_attempts):
        try:
            # Проверяем общий timeout
            if config.timeout and (time.time() - start_time) > config.timeout:
                raise TimeoutError(f"Общий timeout {config.timeout}s превышен")
            
            # Выполняем функцию
            logger.debug(f"Попытка {attempt + 1}/{config.max_attempts}: {func.__name__}")
            result = await func(*args, **kwargs)
            
            if attempt > 0:
                logger.info(f"Операция {func.__name__} успешна после {attempt + 1} попыток")
            
            return result
            
        except Exception as e:
            last_exception = e
            
            # Проверяем нужно ли retry
            if not should_retry(e, config):
                logger.warning(f"Не retry исключение: {type(e).__name__}: {e}")
                raise
            
            # Если это последняя попытка, выбрасываем исключение
            if attempt == config.max_attempts - 1:
                logger.error(f"Все {config.max_attempts} попыток исчерпаны для {func.__name__}")
                break
            
            # Вычисляем задержку
            delay = calculate_delay(attempt, config)
            
            logger.warning(
                f"Попытка {attempt + 1} неудачна для {func.__name__}: "
                f"{type(e).__name__}: {e}. Повтор через {delay:.2f}s"
            )
            
            # Ждем перед следующей попыткой
            await asyncio.sleep(delay)
    
    # Если мы дошли сюда, все попытки исчерпаны
    raise RetryExhaustedError(config.max_attempts, last_exception)


def retry_with_backoff(config: Optional[RetryConfig] = None):
    """
    Декоратор для добавления retry механизма к асинхронным функциям.
    
    Args:
        config: Конфигурация retry
        
    Usage:
        @retry_with_backoff(RetryConfig(max_attempts=5))
        async def my_function():
            # может упасть с сетевой ошибкой
            pass
    """
    if config is None:
        config = RetryConfig()
    
    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            return await async_retry(func, *args, config=config, **kwargs)
        return wrapper
    
    return decorator


# Предустановленные конфигурации для разных сценариев

DATABASE_RETRY_CONFIG = RetryConfig(
    max_attempts=3,
    base_delay=0.5,
    max_delay=10.0,
    backoff_factor=2.0,
    jitter=True,
    timeout=30.0,
    retry_exceptions={
        ConnectionError,
        OSError,
        TimeoutError,
        asyncio.TimeoutError,
        # SQLAlchemy исключения
    }
)

S3_RETRY_CONFIG = RetryConfig(
    max_attempts=5,
    base_delay=1.0,
    max_delay=30.0,
    backoff_factor=2.0,
    jitter=True,
    timeout=60.0,
    retry_exceptions={
        ConnectionError,
        OSError,
        TimeoutError,
        asyncio.TimeoutError,
        # Botocore исключения для S3
    }
)

HTTP_RETRY_CONFIG = RetryConfig(
    max_attempts=3,
    base_delay=1.0,
    max_delay=15.0,
    backoff_factor=1.5,
    jitter=True,
    timeout=45.0,
    retry_exceptions={
        ConnectionError,
        OSError,
        TimeoutError,
        asyncio.TimeoutError,
    }
)


# Удобные функции для часто используемых операций

async def retry_database_operation(func: Callable, *args, **kwargs) -> Any:
    """Retry для операций с базой данных"""
    return await async_retry(func, *args, config=DATABASE_RETRY_CONFIG, **kwargs)


async def retry_s3_operation(func: Callable, *args, **kwargs) -> Any:
    """Retry для операций с S3/MinIO"""
    return await async_retry(func, *args, config=S3_RETRY_CONFIG, **kwargs)


async def retry_http_operation(func: Callable, *args, **kwargs) -> Any:
    """Retry для HTTP запросов"""
    return await async_retry(func, *args, config=HTTP_RETRY_CONFIG, **kwargs) 