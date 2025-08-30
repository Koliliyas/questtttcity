"""
QuestCity Backend - Circuit Breaker Pattern

Circuit Breaker для предотвращения каскадных отказов:
- Состояния: CLOSED, OPEN, HALF_OPEN
- Настраиваемые пороги отказов
- Timeout для восстановления
- Метрики и мониторинг
- Graceful degradation
"""

import asyncio
import logging
import time
from dataclasses import dataclass
from enum import Enum
from functools import wraps
from typing import Any, Callable, Dict, Optional, Set, Type

logger = logging.getLogger(__name__)


class CircuitBreakerState(Enum):
    """Состояния Circuit Breaker"""
    CLOSED = "closed"      # Нормальная работа
    OPEN = "open"          # Блокирует вызовы
    HALF_OPEN = "half_open"  # Тестирует восстановление


@dataclass
class CircuitBreakerConfig:
    """Конфигурация Circuit Breaker"""
    
    failure_threshold: int = 5  # Количество ошибок для открытия
    recovery_timeout: float = 60.0  # Время до попытки восстановления (сек)
    expected_exception: Set[Type[Exception]] = None  # Исключения считающиеся отказом
    success_threshold: int = 3  # Успешных вызовов для закрытия из HALF_OPEN
    timeout: float = 30.0  # Timeout для отдельных вызовов
    
    def __post_init__(self):
        if self.expected_exception is None:
            self.expected_exception = {
                ConnectionError,
                OSError,
                TimeoutError,
                asyncio.TimeoutError,
            }


class CircuitBreakerOpenException(Exception):
    """Исключение когда Circuit Breaker открыт"""
    
    def __init__(self, name: str, failure_count: int):
        self.name = name
        self.failure_count = failure_count
        super().__init__(
            f"Circuit breaker '{name}' is OPEN. "
            f"Failed {failure_count} times. Service temporarily unavailable."
        )


class CircuitBreakerTimeoutException(Exception):
    """Исключение timeout для Circuit Breaker"""
    pass


class CircuitBreaker:
    """
    Реализация Circuit Breaker pattern.
    
    Автоматически переключается между состояниями:
    - CLOSED: Пропускает все вызовы
    - OPEN: Блокирует вызовы при превышении порога ошибок
    - HALF_OPEN: Тестирует восстановление сервиса
    """
    
    def __init__(self, name: str, config: Optional[CircuitBreakerConfig] = None):
        self.name = name
        self.config = config or CircuitBreakerConfig()
        
        # Состояние Circuit Breaker
        self._state = CircuitBreakerState.CLOSED
        self._failure_count = 0
        self._success_count = 0
        self._last_failure_time = 0
        
        # Метрики
        self._total_calls = 0
        self._total_failures = 0
        self._total_successes = 0
        self._state_changes = 0
        
        logger.info(f"Circuit Breaker '{name}' инициализирован в состоянии CLOSED")
    
    @property
    def state(self) -> CircuitBreakerState:
        """Текущее состояние Circuit Breaker"""
        return self._state
    
    @property
    def failure_count(self) -> int:
        """Количество последовательных ошибок"""
        return self._failure_count
    
    @property
    def is_closed(self) -> bool:
        """Circuit Breaker закрыт (нормальная работа)"""
        return self._state == CircuitBreakerState.CLOSED
    
    @property
    def is_open(self) -> bool:
        """Circuit Breaker открыт (блокирует вызовы)"""
        return self._state == CircuitBreakerState.OPEN
    
    @property
    def is_half_open(self) -> bool:
        """Circuit Breaker полуоткрыт (тестирует восстановление)"""
        return self._state == CircuitBreakerState.HALF_OPEN
    
    def get_metrics(self) -> Dict[str, Any]:
        """Получить метрики Circuit Breaker"""
        return {
            "name": self.name,
            "state": self._state.value,
            "failure_count": self._failure_count,
            "success_count": self._success_count,
            "total_calls": self._total_calls,
            "total_failures": self._total_failures,
            "total_successes": self._total_successes,
            "state_changes": self._state_changes,
            "failure_rate": (
                self._total_failures / self._total_calls 
                if self._total_calls > 0 else 0
            ),
            "last_failure_time": self._last_failure_time,
        }
    
    def _change_state(self, new_state: CircuitBreakerState, reason: str = ""):
        """Изменить состояние Circuit Breaker"""
        if self._state != new_state:
            old_state = self._state
            self._state = new_state
            self._state_changes += 1
            
            logger.info(
                f"Circuit Breaker '{self.name}': {old_state.value} -> {new_state.value}"
                f"{f' ({reason})' if reason else ''}"
            )
    
    def _should_attempt_reset(self) -> bool:
        """Проверить можно ли попробовать восстановление"""
        return (
            self._state == CircuitBreakerState.OPEN and
            time.time() - self._last_failure_time >= self.config.recovery_timeout
        )
    
    def _record_success(self):
        """Записать успешный вызов"""
        self._total_calls += 1
        self._total_successes += 1
        
        if self._state == CircuitBreakerState.HALF_OPEN:
            self._success_count += 1
            logger.debug(
                f"Circuit Breaker '{self.name}': "
                f"Успех в HALF_OPEN ({self._success_count}/{self.config.success_threshold})"
            )
            
            # Если достаточно успешных вызовов, закрываем Circuit Breaker
            if self._success_count >= self.config.success_threshold:
                self._failure_count = 0
                self._success_count = 0
                self._change_state(
                    CircuitBreakerState.CLOSED,
                    f"достигнут порог успехов ({self.config.success_threshold})"
                )
        else:
            # В состоянии CLOSED сбрасываем счетчик ошибок при успехе
            self._failure_count = 0
    
    def _record_failure(self, exception: Exception):
        """Записать неудачный вызов"""
        self._total_calls += 1
        self._total_failures += 1
        
        # Проверяем что это ожидаемое исключение
        if not any(isinstance(exception, exc_type) 
                  for exc_type in self.config.expected_exception):
            logger.debug(
                f"Circuit Breaker '{self.name}': "
                f"Игнорируем исключение {type(exception).__name__}"
            )
            return
        
        self._failure_count += 1
        self._last_failure_time = time.time()
        
        logger.warning(
            f"Circuit Breaker '{self.name}': "
            f"Ошибка #{self._failure_count} - {type(exception).__name__}: {exception}"
        )
        
        # Проверяем нужно ли открыть Circuit Breaker
        if self._state == CircuitBreakerState.CLOSED:
            if self._failure_count >= self.config.failure_threshold:
                self._change_state(
                    CircuitBreakerState.OPEN,
                    f"превышен порог ошибок ({self.config.failure_threshold})"
                )
        elif self._state == CircuitBreakerState.HALF_OPEN:
            # В HALF_OPEN любая ошибка возвращает в OPEN
            self._change_state(
                CircuitBreakerState.OPEN,
                "ошибка в состоянии HALF_OPEN"
            )
            self._success_count = 0
    
    async def call(self, func: Callable, *args, **kwargs) -> Any:
        """
        Выполнить функцию через Circuit Breaker.
        
        Args:
            func: Функция для выполнения
            *args: Позиционные аргументы
            **kwargs: Именованные аргументы
            
        Returns:
            Any: Результат выполнения функции
            
        Raises:
            CircuitBreakerOpenException: Если Circuit Breaker открыт
            CircuitBreakerTimeoutException: При превышении timeout
        """
        # Проверяем можно ли попробовать восстановление
        if self._should_attempt_reset():
            self._change_state(
                CircuitBreakerState.HALF_OPEN,
                f"timeout восстановления ({self.config.recovery_timeout}s) истек"
            )
        
        # Если Circuit Breaker открыт, блокируем вызов
        if self._state == CircuitBreakerState.OPEN:
            raise CircuitBreakerOpenException(self.name, self._failure_count)
        
        # Выполняем функцию с timeout
        try:
            result = await asyncio.wait_for(
                func(*args, **kwargs),
                timeout=self.config.timeout
            )
            
            self._record_success()
            return result
            
        except asyncio.TimeoutError:
            timeout_exc = CircuitBreakerTimeoutException(
                f"Timeout {self.config.timeout}s для Circuit Breaker '{self.name}'"
            )
            self._record_failure(timeout_exc)
            raise timeout_exc
        except Exception as e:
            self._record_failure(e)
            raise
    
    def reset(self):
        """Принудительно сбросить Circuit Breaker в состояние CLOSED"""
        logger.info(f"Circuit Breaker '{self.name}': принудительный сброс")
        self._state = CircuitBreakerState.CLOSED
        self._failure_count = 0
        self._success_count = 0
        self._state_changes += 1


def circuit_breaker(name: str, config: Optional[CircuitBreakerConfig] = None):
    """
    Декоратор для добавления Circuit Breaker к функции.
    
    Args:
        name: Имя Circuit Breaker
        config: Конфигурация Circuit Breaker
        
    Usage:
        @circuit_breaker("database", CircuitBreakerConfig(failure_threshold=3))
        async def database_operation():
            # операция с БД
            pass
    """
    # Глобальный реестр Circuit Breaker'ов
    if not hasattr(circuit_breaker, '_breakers'):
        circuit_breaker._breakers = {}
    
    # Создаем или получаем существующий Circuit Breaker
    if name not in circuit_breaker._breakers:
        circuit_breaker._breakers[name] = CircuitBreaker(name, config)
    
    breaker = circuit_breaker._breakers[name]
    
    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            return await breaker.call(func, *args, **kwargs)
        
        # Добавляем доступ к Circuit Breaker через атрибут функции
        wrapper.circuit_breaker = breaker
        return wrapper
    
    return decorator


def get_circuit_breaker(name: str) -> Optional[CircuitBreaker]:
    """Получить Circuit Breaker по имени"""
    return getattr(circuit_breaker, '_breakers', {}).get(name)


def get_all_circuit_breakers() -> Dict[str, CircuitBreaker]:
    """Получить все Circuit Breaker'ы"""
    return getattr(circuit_breaker, '_breakers', {}).copy()


def reset_all_circuit_breakers():
    """Сбросить все Circuit Breaker'ы"""
    breakers = getattr(circuit_breaker, '_breakers', {})
    for breaker in breakers.values():
        breaker.reset()
    logger.info(f"Сброшено {len(breakers)} Circuit Breaker'ов")


# Предустановленные конфигурации

DATABASE_CIRCUIT_BREAKER_CONFIG = CircuitBreakerConfig(
    failure_threshold=3,
    recovery_timeout=30.0,
    success_threshold=2,
    timeout=10.0,
    expected_exception={
        ConnectionError,
        OSError,
        TimeoutError,
        asyncio.TimeoutError,
    }
)

S3_CIRCUIT_BREAKER_CONFIG = CircuitBreakerConfig(
    failure_threshold=5,
    recovery_timeout=60.0,
    success_threshold=3,
    timeout=30.0,
    expected_exception={
        ConnectionError,
        OSError,
        TimeoutError,
        asyncio.TimeoutError,
    }
) 