# QuestCity Backend - Система отказоустойчивости

## Обзор

Реализована комплексная система обработки ошибок подключения к внешним сервисам с graceful degradation и retry механизмами.

## ✅ Что было исправлено

### Критическая задача #8: Обработка ошибок подключения к БД и MinIO

- ✅ **Retry механизмы** с экспоненциальной задержкой
- ✅ **Circuit Breaker pattern** для предотвращения каскадных отказов  
- ✅ **Health Check система** для мониторинга состояния сервисов
- ✅ **Connection pooling** для PostgreSQL
- ✅ **Graceful degradation** при недоступности сервисов
- ✅ **Health API** для мониторинга и Kubernetes probes

## 🔧 Компоненты системы

### 1. Retry механизмы (`core/resilience/retry.py`)

```python
from core.resilience import retry_with_backoff, RetryConfig

# Автоматический retry с экспоненциальной задержкой
@retry_with_backoff(RetryConfig(max_attempts=5))
async def my_function():
    # может упасть с сетевой ошибкой
    pass

# Предустановленные конфигурации
await retry_database_operation(my_db_func)
await retry_s3_operation(my_s3_func)
```

**Возможности:**
- Экспоненциальная задержка с jitter
- Настраиваемые исключения для retry
- Timeout защита
- Логирование попыток

### 2. Circuit Breaker (`core/resilience/circuit_breaker.py`)

```python
from core.resilience import circuit_breaker, CircuitBreakerConfig

# Автоматическая защита от каскадных отказов
@circuit_breaker("database", CircuitBreakerConfig(failure_threshold=3))
async def database_operation():
    # операция с БД
    pass
```

**Состояния:**
- **CLOSED** - нормальная работа
- **OPEN** - блокирует вызовы при превышении порога ошибок
- **HALF_OPEN** - тестирует восстановление сервиса

### 3. Health Check система (`core/resilience/health_check.py`)

```python
from core.resilience.health_check import get_health_checker

health_checker = get_health_checker()

# Проверка доступности сервиса
if health_checker.is_service_available("database"):
    # сервис доступен
    pass

# Получение метрик
metrics = health_checker.get_service_metrics("database")
```

**Возможности:**
- Periodic проверки состояния
- Метрики доступности и времени отклика
- Интеграция с Circuit Breaker
- Graceful degradation

### 4. Улучшенные подключения

#### PostgreSQL (`db/engine.py`, `db/dependencies.py`)
- Connection pooling (20 connections + 30 overflow)
- Автоматический retry при ошибках подключения
- Circuit breaker защита
- Health check интеграция

#### MinIO/S3 (`core/repositories.py`)
- Retry механизм для S3 операций
- Circuit breaker для S3 подключений
- Health check для bucket доступности
- Graceful degradation при недоступности S3

### 5. Health API (`api/health.py`)

#### Основные endpoints:

```bash
# Общий статус (для load balancer)
GET /api/v1/health/

# Детальная информация
GET /api/v1/health/detailed

# Kubernetes probes
GET /api/v1/health/live      # Liveness probe
GET /api/v1/health/ready     # Readiness probe

# Статус конкретного сервиса
GET /api/v1/health/services/database
GET /api/v1/health/services/s3

# Ручной сброс Circuit Breaker
POST /api/v1/health/services/database/reset
```

#### Пример ответа:

```json
{
  "status": "healthy",
  "timestamp": 1705312345.123,
  "services": {
    "total": 2,
    "healthy": 2,
    "degraded": 0,
    "unhealthy": 0
  },
  "message": "All systems operational"
}
```

## 🚀 Автоматическая инициализация

Система автоматически инициализируется при старте приложения (`app.py`):

1. ✅ JWT ключи проверяются/создаются
2. ✅ Health Checker запускается
3. ✅ Регистрируются стандартные health checks (БД, S3)
4. ✅ Circuit Breaker'ы инициализируются
5. ✅ При shutdown - graceful остановка

## 📊 Мониторинг и метрики

### Health Check метрики
- Общая доступность сервисов (%)
- Среднее время отклика
- Количество последовательных ошибок
- История проверок

### Circuit Breaker метрики
- Текущее состояние
- Общее количество вызовов
- Коэффициент ошибок
- Количество переключений состояний

### Логирование
- Все retry попытки логируются
- Изменения состояний Circuit Breaker
- Health check результаты
- Ошибки подключения к сервисам

## 🔧 Конфигурация

### PostgreSQL connection pooling
```python
# db/engine.py
pool_size=20              # Базовое количество соединений
max_overflow=30           # Дополнительные при нагрузке  
pool_timeout=30           # Timeout получения из пула
pool_recycle=3600         # Пересоздание каждый час
pool_pre_ping=True        # Проверка перед использованием
```

### Retry конфигурации
```python
# Предустановленные
DATABASE_RETRY_CONFIG = RetryConfig(
    max_attempts=3,
    base_delay=0.5,
    max_delay=10.0,
    timeout=30.0
)

S3_RETRY_CONFIG = RetryConfig(
    max_attempts=5,
    base_delay=1.0, 
    max_delay=30.0,
    timeout=60.0
)
```

### Circuit Breaker конфигурации
```python
DATABASE_CIRCUIT_BREAKER_CONFIG = CircuitBreakerConfig(
    failure_threshold=3,      # Ошибок для открытия
    recovery_timeout=30.0,    # Время до попытки восстановления
    success_threshold=2,      # Успехов для закрытия
    timeout=10.0             # Timeout операций
)
```

## 🔄 Graceful Degradation

### Сценарии деградации:

1. **БД недоступна**
   - Блокируются операции записи
   - Read-only операции продолжают работать если возможно
   - Возвращается HTTP 503 для критических endpoints

2. **S3/MinIO недоступен**
   - Блокируется загрузка файлов
   - Приложение продолжает работать без файловых операций
   - Graceful fallback для аватаров/изображений

3. **Частичная деградация**
   - Система продолжает работать в ограниченном режиме
   - Health status: "degraded"
   - Некритические функции отключаются

## 🚨 Алерты и мониторинг

### Рекомендуемые алерты:
- Circuit Breaker в состоянии OPEN > 5 минут
- Health check failure rate > 50%
- Database connection pool exhaustion
- S3 операции fail rate > 30%

### Интеграция с мониторингом:
- Health endpoints для Prometheus scraping
- Structured logging для анализа
- Metrics API для внешних систем

## 📋 Checklist для разработчиков

При добавлении новых внешних зависимостей:

- [ ] Добавить retry механизм
- [ ] Настроить Circuit Breaker
- [ ] Создать health check функцию
- [ ] Зарегистрировать в Health Checker
- [ ] Добавить graceful degradation логику
- [ ] Обновить мониторинг/алерты

## 🔗 Связанные файлы

- `core/resilience/` - основные компоненты
- `db/engine.py` - PostgreSQL pooling
- `db/dependencies.py` - БД resilience
- `core/repositories.py` - S3 resilience  
- `api/health.py` - Health API
- `app.py` - инициализация системы

---

*Документация создана: 15 января 2025*  
*Статус: ✅ Критическая задача #8 выполнена* 