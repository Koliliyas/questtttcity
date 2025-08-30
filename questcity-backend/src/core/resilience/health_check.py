"""
QuestCity Backend - Health Check System

Система мониторинга состояния внешних сервисов:
- Health checks для БД, S3, внешних API
- Periodic проверки состояния
- Graceful degradation при отказах
- Метрики доступности
- Integration с Circuit Breaker
"""

import asyncio
import logging
import time
from dataclasses import dataclass
from enum import Enum
from typing import Any, Callable, Dict, List, Optional

logger = logging.getLogger(__name__)


class ServiceHealthStatus(Enum):
    """Статусы health check"""
    HEALTHY = "healthy"
    DEGRADED = "degraded"  # Частично работает
    UNHEALTHY = "unhealthy"
    UNKNOWN = "unknown"    # Не проверен


@dataclass
class HealthCheckResult:
    """Результат health check"""
    service_name: str
    status: ServiceHealthStatus
    response_time_ms: float
    timestamp: float
    details: Dict[str, Any]
    error: Optional[str] = None


@dataclass
class HealthCheckConfig:
    """Конфигурация health check"""
    name: str
    check_interval: float = 30.0  # Интервал проверки в секундах
    timeout: float = 10.0         # Timeout для проверки
    healthy_threshold: int = 2    # Успешных проверок для HEALTHY
    unhealthy_threshold: int = 3  # Неудачных проверок для UNHEALTHY
    degraded_threshold: int = 5   # Неудачных проверок для DEGRADED
    enabled: bool = True


class HealthChecker:
    """
    Система Health Check для мониторинга внешних сервисов.
    
    Автоматически выполняет periodic проверки и отслеживает состояние.
    """
    
    def __init__(self):
        self._checks: Dict[str, HealthCheckConfig] = {}
        self._check_functions: Dict[str, Callable] = {}
        self._results: Dict[str, List[HealthCheckResult]] = {}
        self._current_status: Dict[str, ServiceHealthStatus] = {}
        self._consecutive_failures: Dict[str, int] = {}
        self._consecutive_successes: Dict[str, int] = {}
        self._tasks: Dict[str, asyncio.Task] = {}
        self._running = False
        
        logger.info("Health Checker инициализирован")
    
    def register_check(
        self,
        config: HealthCheckConfig,
        check_function: Callable
    ):
        """
        Регистрирует health check для сервиса.
        
        Args:
            config: Конфигурация health check
            check_function: Async функция для проверки (должна возвращать Dict с деталями)
        """
        self._checks[config.name] = config
        self._check_functions[config.name] = check_function
        self._results[config.name] = []
        self._current_status[config.name] = ServiceHealthStatus.UNKNOWN
        self._consecutive_failures[config.name] = 0
        self._consecutive_successes[config.name] = 0
        
        logger.info(f"Зарегистрирован health check: {config.name}")
        
        # Если уже запущен, запускаем task для нового check
        if self._running and config.enabled:
            self._start_check_task(config.name)
    
    def unregister_check(self, service_name: str):
        """Отменяет регистрацию health check"""
        if service_name in self._checks:
            # Останавливаем task
            if service_name in self._tasks:
                self._tasks[service_name].cancel()
                del self._tasks[service_name]
            
            # Удаляем данные
            del self._checks[service_name]
            del self._check_functions[service_name]
            del self._results[service_name]
            del self._current_status[service_name]
            del self._consecutive_failures[service_name]
            del self._consecutive_successes[service_name]
            
            logger.info(f"Health check {service_name} отменен")
    
    async def check_service(self, service_name: str) -> HealthCheckResult:
        """
        Выполняет единичную проверку сервиса.
        
        Args:
            service_name: Имя сервиса
            
        Returns:
            HealthCheckResult: Результат проверки
        """
        if service_name not in self._checks:
            raise ValueError(f"Health check для {service_name} не зарегистрирован")
        
        config = self._checks[service_name]
        check_function = self._check_functions[service_name]
        
        start_time = time.time()
        
        try:
            # Выполняем проверку с timeout
            details = await asyncio.wait_for(
                check_function(),
                timeout=config.timeout
            )
            
            response_time = (time.time() - start_time) * 1000
            
            result = HealthCheckResult(
                service_name=service_name,
                status=ServiceHealthStatus.HEALTHY,
                response_time_ms=response_time,
                timestamp=time.time(),
                details=details or {}
            )
            
            logger.debug(f"Health check {service_name}: OK ({response_time:.1f}ms)")
            
        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            
            result = HealthCheckResult(
                service_name=service_name,
                status=ServiceHealthStatus.UNHEALTHY,
                response_time_ms=response_time,
                timestamp=time.time(),
                details={},
                error=str(e)
            )
            
            logger.warning(f"Health check {service_name}: FAIL - {type(e).__name__}: {e}")
        
        # Обновляем статистику
        self._update_service_status(result)
        
        return result
    
    def _update_service_status(self, result: HealthCheckResult):
        """Обновляет статус сервиса на основе результата"""
        service_name = result.service_name
        config = self._checks[service_name]
        
        # Добавляем результат в историю (ограничиваем размер)
        self._results[service_name].append(result)
        if len(self._results[service_name]) > 100:
            self._results[service_name] = self._results[service_name][-50:]
        
        # Обновляем счетчики
        if result.status == ServiceHealthStatus.HEALTHY:
            self._consecutive_successes[service_name] += 1
            self._consecutive_failures[service_name] = 0
        else:
            self._consecutive_failures[service_name] += 1
            self._consecutive_successes[service_name] = 0
        
        # Определяем новый статус
        old_status = self._current_status[service_name]
        new_status = self._calculate_status(service_name, config)
        
        if new_status != old_status:
            self._current_status[service_name] = new_status
            logger.info(
                f"Health status {service_name}: {old_status.value} -> {new_status.value}"
            )
    
    def _calculate_status(
        self,
        service_name: str,
        config: HealthCheckConfig
    ) -> ServiceHealthStatus:
        """Вычисляет статус сервиса на основе истории"""
        successes = self._consecutive_successes[service_name]
        failures = self._consecutive_failures[service_name]
        current = self._current_status[service_name]
        
        # Переходы в HEALTHY
        if successes >= config.healthy_threshold:
            return ServiceHealthStatus.HEALTHY
        
        # Переходы в UNHEALTHY
        if failures >= config.unhealthy_threshold:
            return ServiceHealthStatus.UNHEALTHY
        
        # Переходы в DEGRADED (промежуточное состояние)
        if failures >= config.degraded_threshold and current != ServiceHealthStatus.UNHEALTHY:
            return ServiceHealthStatus.DEGRADED
        
        # Сохраняем текущий статус
        return current
    
    def _start_check_task(self, service_name: str):
        """Запускает периодическую проверку для сервиса"""
        if service_name in self._tasks:
            self._tasks[service_name].cancel()
        
        config = self._checks[service_name]
        if not config.enabled:
            return
        
        async def check_loop():
            while True:
                try:
                    await self.check_service(service_name)
                except Exception as e:
                    logger.error(f"Ошибка в health check task {service_name}: {e}")
                
                await asyncio.sleep(config.check_interval)
        
        self._tasks[service_name] = asyncio.create_task(check_loop())
    
    async def start(self):
        """Запускает все health checks"""
        if self._running:
            return
        
        self._running = True
        logger.info("Запуск Health Checker...")
        
        # Запускаем tasks для всех зарегистрированных checks
        for service_name in self._checks:
            self._start_check_task(service_name)
        
        logger.info(f"Health Checker запущен ({len(self._checks)} сервисов)")
    
    async def stop(self):
        """Останавливает все health checks"""
        if not self._running:
            return
        
        self._running = False
        logger.info("Остановка Health Checker...")
        
        # Отменяем все tasks
        for task in self._tasks.values():
            task.cancel()
        
        # Ждем завершения
        if self._tasks:
            await asyncio.gather(*self._tasks.values(), return_exceptions=True)
        
        self._tasks.clear()
        logger.info("Health Checker остановлен")
    
    def get_service_status(self, service_name: str) -> ServiceHealthStatus:
        """Получает текущий статус сервиса"""
        return self._current_status.get(service_name, ServiceHealthStatus.UNKNOWN)
    
    def is_service_healthy(self, service_name: str) -> bool:
        """Проверяет здоров ли сервис"""
        return self.get_service_status(service_name) == ServiceHealthStatus.HEALTHY
    
    def is_service_available(self, service_name: str) -> bool:
        """Проверяет доступен ли сервис (HEALTHY, DEGRADED или UNKNOWN при старте)"""
        status = self.get_service_status(service_name)
        # UNKNOWN считается доступным при старте системы
        return status in (ServiceHealthStatus.HEALTHY, ServiceHealthStatus.DEGRADED, ServiceHealthStatus.UNKNOWN)
    
    def get_service_metrics(self, service_name: str) -> Dict[str, Any]:
        """Получает метрики сервиса"""
        if service_name not in self._checks:
            return {}
        
        results = self._results[service_name]
        if not results:
            return {
                "service_name": service_name,
                "status": self._current_status[service_name].value,
                "total_checks": 0
            }
        
        # Вычисляем метрики
        total_checks = len(results)
        healthy_checks = sum(1 for r in results if r.status == ServiceHealthStatus.HEALTHY)
        recent_results = results[-10:]  # Последние 10 проверок
        recent_response_times = [r.response_time_ms for r in recent_results]
        
        return {
            "service_name": service_name,
            "status": self._current_status[service_name].value,
            "total_checks": total_checks,
            "healthy_checks": healthy_checks,
            "availability": (healthy_checks / total_checks) * 100 if total_checks > 0 else 0,
            "consecutive_failures": self._consecutive_failures[service_name],
            "consecutive_successes": self._consecutive_successes[service_name],
            "avg_response_time_ms": (
                sum(recent_response_times) / len(recent_response_times)
                if recent_response_times else 0
            ),
            "last_check": results[-1].timestamp if results else 0,
            "last_error": next(
                (r.error for r in reversed(results) if r.error),
                None
            )
        }
    
    def get_overall_health(self) -> Dict[str, Any]:
        """Получает общее состояние всех сервисов"""
        services = {}
        total_services = len(self._checks)
        healthy_services = 0
        degraded_services = 0
        unhealthy_services = 0
        
        for service_name in self._checks:
            status = self._current_status[service_name]
            services[service_name] = {
                "status": status.value,
                "metrics": self.get_service_metrics(service_name)
            }
            
            if status == ServiceHealthStatus.HEALTHY:
                healthy_services += 1
            elif status == ServiceHealthStatus.DEGRADED:
                degraded_services += 1
            elif status == ServiceHealthStatus.UNHEALTHY:
                unhealthy_services += 1
        
        # Определяем общий статус
        if unhealthy_services == 0 and degraded_services == 0:
            overall_status = ServiceHealthStatus.HEALTHY
        elif unhealthy_services == 0:
            overall_status = ServiceHealthStatus.DEGRADED
        else:
            overall_status = ServiceHealthStatus.UNHEALTHY
        
        return {
            "overall_status": overall_status.value,
            "total_services": total_services,
            "healthy_services": healthy_services,
            "degraded_services": degraded_services,
            "unhealthy_services": unhealthy_services,
            "services": services,
            "timestamp": time.time()
        }


# Глобальный instance Health Checker
_health_checker = HealthChecker()


def get_health_checker() -> HealthChecker:
    """Получает глобальный instance Health Checker"""
    return _health_checker


# Convenience функции для часто используемых health checks

async def database_health_check() -> Dict[str, Any]:
    """Health check для базы данных"""
    from src.db.engine import engine
    from sqlalchemy import text
    
    try:
        async with engine.begin() as conn:
            result = await conn.execute(text("SELECT 1"))
            row = result.fetchone()  # fetchone() не асинхронный в SQLAlchemy 2.x
            if row is None:
                raise ConnectionError("No result from database")
        
        return {
            "database": "postgresql",
            "connection": "ok"
        }
    except Exception as e:
        raise ConnectionError(f"Database connection failed: {e}")


async def s3_health_check() -> Dict[str, Any]:
    """Health check для S3/MinIO"""
    from src.settings import get_settings, S3Settings
    from aioboto3 import Session
    from botocore.config import Config
    import os
    
    try:
        s3_settings = get_settings(S3Settings)
        
        # Создаем S3 клиент напрямую для health check (избегаем циклической зависимости)
        session = Session()
        client = await session.client(
            service_name="s3",
            endpoint_url=s3_settings.endpoint,
            aws_access_key_id=s3_settings.access_key,
            aws_secret_access_key=s3_settings.secret_key,
            config=Config(
                retries={"max_attempts": s3_settings.max_attempts, "mode": s3_settings.mode},
                max_pool_connections=5,
            ),
        ).__aenter__()
        
        try:
            # Простая проверка доступности bucket
            await client.head_bucket(Bucket=s3_settings.bucket_name)
            
            return {
                "s3_service": "minio",
                "bucket": s3_settings.bucket_name,
                "connection": "ok"
            }
        finally:
            # Закрываем клиент
            try:
                await client.__aexit__(None, None, None)
            except:
                pass
        
    except Exception as e:
        raise ConnectionError(f"S3 connection failed: {e}")


def register_default_health_checks():
    """Регистрирует стандартные health checks"""
    health_checker = get_health_checker()
    
    # Database health check
    health_checker.register_check(
        HealthCheckConfig(
            name="database",
            check_interval=30.0,
            timeout=5.0,
            healthy_threshold=2,
            unhealthy_threshold=3
        ),
        database_health_check
    )
    
    # S3/MinIO health check - ВРЕМЕННО ОТКЛЮЧЕН для тестирования авторизации
    # health_checker.register_check(
    #     HealthCheckConfig(
    #         name="s3",
    #         check_interval=60.0,
    #         timeout=10.0,
    #         healthy_threshold=2,
    #         unhealthy_threshold=3
    #     ),
    #     s3_health_check
    # ) 