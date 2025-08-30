"""
QuestCity Backend - Health Check API

REST API endpoints для мониторинга состояния системы:
- Общий статус системы
- Детальная информация о сервисах  
- Метрики Circuit Breaker'ов
- Информация о ready/live состоянии
"""

import logging
from typing import Any, Dict

from fastapi import APIRouter, HTTPException, status
from fastapi.responses import JSONResponse

from src.core.resilience.circuit_breaker import get_all_circuit_breakers
from src.core.resilience.health_check import get_health_checker, ServiceHealthStatus

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/health", tags=["Health Check"])


@router.get("/", summary="Общий статус здоровья системы")
async def get_health() -> Dict[str, Any]:
    """
    Возвращает общий статус здоровья всей системы.
    
    Используется для load balancer health checks.
    """
    try:
        health_checker = get_health_checker()
        overall_health = health_checker.get_overall_health()
        
        # Определяем HTTP статус код
        if overall_health["overall_status"] == ServiceHealthStatus.HEALTHY.value:
            status_code = status.HTTP_200_OK
        elif overall_health["overall_status"] == ServiceHealthStatus.DEGRADED.value:
            status_code = status.HTTP_200_OK  # Система работает, но деградированно
        else:
            status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        
        return JSONResponse(
            status_code=status_code,
            content={
                "status": overall_health["overall_status"],
                "timestamp": overall_health["timestamp"],
                "services": {
                    "total": overall_health["total_services"],
                    "healthy": overall_health["healthy_services"],
                    "degraded": overall_health["degraded_services"],
                    "unhealthy": overall_health["unhealthy_services"],
                },
                "message": _get_health_message(overall_health["overall_status"])
            }
        )
        
    except Exception as e:
        logger.error(f"Ошибка в health check endpoint: {e}")
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "unhealthy",
                "message": "Health check system error",
                "error": str(e)
            }
        )


@router.get("/detailed", summary="Детальная информация о состоянии системы")
async def get_detailed_health() -> Dict[str, Any]:
    """
    Возвращает подробную информацию о состоянии всех сервисов.
    
    Включает метрики, ошибки, и статистику.
    """
    try:
        health_checker = get_health_checker()
        overall_health = health_checker.get_overall_health()
        
        # Добавляем метрики Circuit Breaker'ов
        circuit_breakers = get_all_circuit_breakers()
        circuit_breaker_metrics = {}
        
        for name, breaker in circuit_breakers.items():
            circuit_breaker_metrics[name] = breaker.get_metrics()
        
        return {
            "overall_status": overall_health["overall_status"],
            "timestamp": overall_health["timestamp"],
            "summary": {
                "total_services": overall_health["total_services"],
                "healthy_services": overall_health["healthy_services"],
                "degraded_services": overall_health["degraded_services"],
                "unhealthy_services": overall_health["unhealthy_services"],
            },
            "services": overall_health["services"],
            "circuit_breakers": circuit_breaker_metrics,
            "message": _get_health_message(overall_health["overall_status"])
        }
        
    except Exception as e:
        logger.error(f"Ошибка в detailed health check endpoint: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Health check system error: {e}"
        )


@router.get("/live", summary="Liveness probe")
async def get_liveness() -> Dict[str, Any]:
    """
    Liveness probe для Kubernetes.
    
    Проверяет что приложение запущено и отвечает.
    Не проверяет внешние зависимости.
    """
    try:
        health_checker = get_health_checker()
        return {
            "status": "alive",
            "timestamp": health_checker.get_overall_health()["timestamp"],
            "message": "Application is running"
        }
    except Exception as e:
        logger.error(f"Ошибка в liveness probe: {e}")
        return {
            "status": "alive",
            "timestamp": "unknown",
            "message": "Application is running"
        }


@router.get("/ready", summary="Readiness probe") 
async def get_readiness() -> Dict[str, Any]:
    """
    Readiness probe для Kubernetes.
    
    Проверяет что приложение готово принимать трафик.
    Проверяет критические зависимости (БД).
    """
    try:
        health_checker = get_health_checker()
        
        # Проверяем критические сервисы
        database_available = health_checker.is_service_available("database")
        
        if database_available:
            status_code = status.HTTP_200_OK
            ready_status = "ready"
            message = "Application is ready to serve traffic"
        else:
            status_code = status.HTTP_503_SERVICE_UNAVAILABLE
            ready_status = "not_ready"
            message = "Critical services unavailable"
        
        return JSONResponse(
            status_code=status_code,
            content={
                "status": ready_status,
                "timestamp": health_checker.get_overall_health()["timestamp"],
                "critical_services": {
                    "database": health_checker.get_service_status("database").value,
                },
                "message": message
            }
        )
        
    except Exception as e:
        logger.error(f"Ошибка в readiness probe: {e}")
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "not_ready",
                "message": "Readiness check failed",
                "error": str(e)
            }
        )


@router.get("/services/{service_name}", summary="Статус конкретного сервиса")
async def get_service_health(service_name: str) -> Dict[str, Any]:
    """
    Возвращает детальную информацию о конкретном сервисе.
    
    Args:
        service_name: Имя сервиса (database, s3, etc.)
    """
    try:
        health_checker = get_health_checker()
        
        # Проверяем что сервис существует
        metrics = health_checker.get_service_metrics(service_name)
        if not metrics:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Service '{service_name}' not found"
            )
        
        return {
            "service_name": service_name,
            "status": health_checker.get_service_status(service_name).value,
            "metrics": metrics,
            "timestamp": health_checker.get_overall_health()["timestamp"]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Ошибка в service health check для {service_name}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error checking service {service_name}: {e}"
        )


@router.post("/services/{service_name}/reset", summary="Сброс Circuit Breaker сервиса")
async def reset_service_circuit_breaker(service_name: str) -> Dict[str, Any]:
    """
    Принудительно сбрасывает Circuit Breaker для сервиса.
    
    Используется для ручного восстановления после устранения проблем.
    
    Args:
        service_name: Имя сервиса
    """
    try:
        from core.resilience.circuit_breaker import get_circuit_breaker
        
        breaker = get_circuit_breaker(service_name)
        if not breaker:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Circuit breaker for service '{service_name}' not found"
            )
        
        breaker.reset()
        
        logger.info(f"Circuit breaker для сервиса '{service_name}' сброшен вручную")
        
        return {
            "service_name": service_name,
            "action": "reset",
            "status": "success",
            "message": f"Circuit breaker for '{service_name}' has been reset",
            "timestamp": health_checker.get_overall_health()["timestamp"]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Ошибка сброса Circuit Breaker для {service_name}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error resetting circuit breaker for {service_name}: {e}"
        )


def _get_health_message(status: str) -> str:
    """Возвращает понятное сообщение о статусе здоровья"""
    messages = {
        ServiceHealthStatus.HEALTHY.value: "All systems operational",
        ServiceHealthStatus.DEGRADED.value: "Some services experiencing issues, but system is functional",
        ServiceHealthStatus.UNHEALTHY.value: "Critical services unavailable",
        ServiceHealthStatus.UNKNOWN.value: "System status unknown"
    }
    return messages.get(status, "Unknown status") 