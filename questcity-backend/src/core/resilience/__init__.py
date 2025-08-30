"""
QuestCity Backend - Resilience Package

Компоненты отказоустойчивости:
- Retry механизмы с экспоненциальной задержкой
- Circuit Breaker pattern
- Health checks для внешних сервисов
- Graceful degradation
"""

from .circuit_breaker import (
    CircuitBreaker, 
    CircuitBreakerState,
    circuit_breaker,
    S3_CIRCUIT_BREAKER_CONFIG,
    DATABASE_CIRCUIT_BREAKER_CONFIG
)
from .health_check import HealthChecker, ServiceHealthStatus
from .retry import (
    RetryConfig, 
    retry_with_backoff, 
    async_retry,
    S3_RETRY_CONFIG,
    DATABASE_RETRY_CONFIG,
    HTTP_RETRY_CONFIG
)

__all__ = [
    "CircuitBreaker",
    "CircuitBreakerState", 
    "circuit_breaker",
    "S3_CIRCUIT_BREAKER_CONFIG",
    "DATABASE_CIRCUIT_BREAKER_CONFIG",
    "HealthChecker",
    "ServiceHealthStatus",
    "RetryConfig",
    "retry_with_backoff",
    "async_retry",
    "S3_RETRY_CONFIG",
    "DATABASE_RETRY_CONFIG", 
    "HTTP_RETRY_CONFIG"
] 