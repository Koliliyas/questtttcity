#!/usr/bin/env python3
"""
🤖 Генератор resilient сервисов для QuestCity Backend

Автоматически создает сервисы с встроенными resilience паттернами:
- Retry механизм
- Circuit Breaker  
- Health Check
- Graceful Degradation
- Exception classes
- Logging

Использование:
    python scripts/generate_resilient_service.py --name PaymentService --type repository
    python scripts/generate_resilient_service.py --name NotificationAPI --type api
"""

import argparse
import os
from pathlib import Path
from typing import Optional
import textwrap


def to_snake_case(name: str) -> str:
    """Конвертирует CamelCase в snake_case"""
    import re
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


def to_upper_snake_case(name: str) -> str:
    """Конвертирует в UPPER_SNAKE_CASE для констант"""
    return to_snake_case(name).upper()


class ResilientServiceGenerator:
    def __init__(self, name: str, service_type: str, base_path: Path):
        self.name = name
        self.service_type = service_type
        self.base_path = base_path
        self.snake_name = to_snake_case(name)
        self.upper_snake_name = to_upper_snake_case(name)
        
    def generate_repository(self) -> str:
        """Генерирует Repository с resilience паттернами"""
        return textwrap.dedent(f'''
        """
        {self.name} Repository с встроенными resilience паттернами
        
        Автоматически сгенерировано: scripts/generate_resilient_service.py
        """
        
        import logging
        from typing import Dict, Any, Optional
        from core.resilience.retry import retry_with_backoff, RetryConfig
        from core.resilience.circuit_breaker import circuit_breaker, CircuitBreakerConfig
        from core.resilience.health_check import get_health_checker
        
        logger = logging.getLogger(__name__)
        
        
        # Конфигурация retry для {self.name}
        {self.upper_snake_name}_RETRY_CONFIG = RetryConfig(
            max_attempts=3,
            base_delay=1.0,
            max_delay=60.0,
            backoff_factor=2.0,
            jitter=True,
            retryable_exceptions=(ConnectionError, TimeoutError, Exception)
        )
        
        # Конфигурация Circuit Breaker для {self.name}
        {self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG = CircuitBreakerConfig(
            failure_threshold=5,
            timeout_duration=60.0,
            success_threshold=3
        )
        
        
        class {self.name}UnavailableError(Exception):
            """{self.name} недоступен"""
            pass
        
        
        class {self.name}Repository:
            """
            Repository для работы с {self.name}
            
            Включает все resilience паттерны:
            - Retry механизм с экспоненциальным backoff
            - Circuit Breaker для предотвращения каскадных сбоев
            - Health Check для мониторинга доступности
            - Graceful Degradation при недоступности
            """
            
            def __init__(self, client: Any):  # Замените Any на реальный тип клиента
                self._client = client
                logger.info(f"{self.name}Repository инициализирован")
            
            @retry_with_backoff({self.upper_snake_name}_RETRY_CONFIG)
            @circuit_breaker("{self.snake_name}", {self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG)
            async def create(self, data: Dict[str, Any]) -> Dict[str, Any]:
                """
                Создать новую запись в {self.name}
                
                Args:
                    data: Данные для создания
                    
                Returns:
                    Результат создания
                    
                Raises:
                    {self.name}UnavailableError: Если сервис недоступен
                """
                health_checker = get_health_checker()
                if not health_checker.is_service_available("{self.snake_name}"):
                    logger.warning(f"{self.name} недоступен по health check")
                    raise {self.name}UnavailableError(f"{self.name} is currently unavailable")
                
                logger.info(f"Создание записи в {self.name}: {{data}}")
                result = await self._client.create(data)
                logger.info(f"Запись успешно создана в {self.name}: {{result}}")
                return result
            
            @retry_with_backoff({self.upper_snake_name}_RETRY_CONFIG)
            @circuit_breaker("{self.snake_name}", {self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG)
            async def get(self, id: str) -> Optional[Dict[str, Any]]:
                """
                Получить запись из {self.name}
                
                Args:
                    id: Идентификатор записи
                    
                Returns:
                    Данные записи или None
                    
                Raises:
                    {self.name}UnavailableError: Если сервис недоступен
                """
                health_checker = get_health_checker()
                if not health_checker.is_service_available("{self.snake_name}"):
                    logger.warning(f"{self.name} недоступен по health check")
                    raise {self.name}UnavailableError(f"{self.name} is currently unavailable")
                
                logger.info(f"Получение записи из {self.name}: {{id}}")
                result = await self._client.get(id)
                logger.info(f"Запись получена из {self.name}: {{result}}")
                return result
            
            async def create_with_fallback(self, data: Dict[str, Any]) -> Dict[str, Any]:
                """
                Создать с fallback логикой
                
                Args:
                    data: Данные для создания
                    
                Returns:
                    Результат создания или fallback результат
                """
                try:
                    return await self.create(data)
                except {self.name}UnavailableError:
                    logger.warning(f"{self.name} недоступен, используется fallback")
                    return self._get_create_fallback(data)
            
            async def get_with_fallback(self, id: str) -> Optional[Dict[str, Any]]:
                """
                Получить с fallback логикой
                
                Args:
                    id: Идентификатор записи
                    
                Returns:
                    Данные записи, cached результат или None
                """
                try:
                    return await self.get(id)
                except {self.name}UnavailableError:
                    logger.warning(f"{self.name} недоступен, используется fallback")
                    return self._get_cached_result(id)
            
            def _get_create_fallback(self, data: Dict[str, Any]) -> Dict[str, Any]:
                """Fallback для создания записи"""
                # TODO: Реализовать fallback логику
                return {{"id": "fallback", "status": "pending", "data": data}}
            
            def _get_cached_result(self, id: str) -> Optional[Dict[str, Any]]:
                """Получить cached результат"""
                # TODO: Реализовать кеширование
                return None
        
        
        # Health Check функция
        async def check_{self.snake_name}_health() -> bool:
            """
            Health check для {self.name}
            
            Returns:
                True если сервис доступен, False иначе
            """
            try:
                # TODO: Реализовать проверку здоровья сервиса
                # Например: response = await client.ping()
                # return response.status == 200
                logger.info(f"Health check для {self.name}: ОК")
                return True
            except Exception as e:
                logger.error(f"Health check для {self.name} failed: {{e}}")
                return False
        
        
        def register_{self.snake_name}_health_check():
            """Регистрирует health check в системе"""
            health_checker = get_health_checker()
            health_checker.register_check("{self.snake_name}", check_{self.snake_name}_health)
            logger.info(f"Health check для {self.name} зарегистрирован")
        ''').strip()
    
    def generate_api_client(self) -> str:
        """Генерирует API Client с resilience паттернами"""
        return textwrap.dedent(f'''
        """
        {self.name} API Client с встроенными resilience паттернами
        
        Автоматически сгенерировано: scripts/generate_resilient_service.py
        """
        
        import logging
        from typing import Dict, Any, Optional
        import httpx
        from core.resilience.retry import retry_with_backoff
        from core.resilience.circuit_breaker import circuit_breaker
        from core.resilience.health_check import get_health_checker
        from core.resilience.retry import HTTP_RETRY_CONFIG
        from core.resilience.circuit_breaker import CircuitBreakerConfig
        
        logger = logging.getLogger(__name__)
        
        
        # Конфигурация Circuit Breaker для {self.name} API
        {self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG = CircuitBreakerConfig(
            failure_threshold=3,
            timeout_duration=30.0,
            success_threshold=2
        )
        
        
        class {self.name}APIError(Exception):
            """{self.name} API ошибка"""
            pass
        
        
        class {self.name}UnavailableError(Exception):
            """{self.name} API недоступно"""
            pass
        
        
        class {self.name}Client:
            """
            HTTP клиент для {self.name} API
            
            Включает все resilience паттерны:
            - Retry механизм для HTTP запросов
            - Circuit Breaker для API endpoints
            - Health Check для мониторинга API
            - Timeout конфигурация
            - Graceful Degradation при недоступности
            """
            
            def __init__(self, base_url: str, api_key: Optional[str] = None, timeout: int = 30):
                self.base_url = base_url.rstrip('/')
                self.api_key = api_key
                self.timeout = timeout
                self._headers = {{"Content-Type": "application/json"}}
                if api_key:
                    self._headers["Authorization"] = f"Bearer {{api_key}}"
                logger.info(f"{self.name}Client инициализирован: {{base_url}}")
            
            @retry_with_backoff(HTTP_RETRY_CONFIG)
            @circuit_breaker("{self.snake_name}_api", {self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG)
            async def get(self, endpoint: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
                """
                GET запрос к {self.name} API
                
                Args:
                    endpoint: API endpoint
                    params: Query параметры
                    
                Returns:
                    Ответ API
                    
                Raises:
                    {self.name}UnavailableError: Если API недоступно
                    {self.name}APIError: При ошибке API
                """
                health_checker = get_health_checker()
                if not health_checker.is_service_available("{self.snake_name}_api"):
                    logger.warning(f"{self.name} API недоступно по health check")
                    raise {self.name}UnavailableError(f"{self.name} API is currently unavailable")
                
                url = f"{{self.base_url}}/{{endpoint.lstrip('/')}}"
                logger.info(f"GET запрос к {self.name} API: {{url}}")
                
                try:
                    async with httpx.AsyncClient(timeout=self.timeout) as client:
                        response = await client.get(url, headers=self._headers, params=params)
                        response.raise_for_status()
                        result = response.json()
                        logger.info(f"GET запрос к {self.name} API успешен: {{len(str(result))}} символов")
                        return result
                except httpx.HTTPStatusError as e:
                    logger.error(f"HTTP ошибка {self.name} API: {{e.response.status_code}} - {{e.response.text}}")
                    raise {self.name}APIError(f"API error: {{e.response.status_code}}")
                except httpx.RequestError as e:
                    logger.error(f"Ошибка соединения с {self.name} API: {{e}}")
                    raise {self.name}UnavailableError(f"Connection error: {{e}}")
            
            @retry_with_backoff(HTTP_RETRY_CONFIG)
            @circuit_breaker("{self.snake_name}_api", {self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG)
            async def post(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
                """
                POST запрос к {self.name} API
                
                Args:
                    endpoint: API endpoint
                    data: Данные для отправки
                    
                Returns:
                    Ответ API
                    
                Raises:
                    {self.name}UnavailableError: Если API недоступно
                    {self.name}APIError: При ошибке API
                """
                health_checker = get_health_checker()
                if not health_checker.is_service_available("{self.snake_name}_api"):
                    logger.warning(f"{self.name} API недоступно по health check")
                    raise {self.name}UnavailableError(f"{self.name} API is currently unavailable")
                
                url = f"{{self.base_url}}/{{endpoint.lstrip('/')}}"
                logger.info(f"POST запрос к {self.name} API: {{url}}")
                
                try:
                    async with httpx.AsyncClient(timeout=self.timeout) as client:
                        response = await client.post(url, headers=self._headers, json=data)
                        response.raise_for_status()
                        result = response.json()
                        logger.info(f"POST запрос к {self.name} API успешен: {{len(str(result))}} символов")
                        return result
                except httpx.HTTPStatusError as e:
                    logger.error(f"HTTP ошибка {self.name} API: {{e.response.status_code}} - {{e.response.text}}")
                    raise {self.name}APIError(f"API error: {{e.response.status_code}}")
                except httpx.RequestError as e:
                    logger.error(f"Ошибка соединения с {self.name} API: {{e}}")
                    raise {self.name}UnavailableError(f"Connection error: {{e}}")
            
            async def get_with_fallback(self, endpoint: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
                """
                GET запрос с fallback логикой
                
                Args:
                    endpoint: API endpoint
                    params: Query параметры
                    
                Returns:
                    Ответ API или fallback результат
                """
                try:
                    return await self.get(endpoint, params)
                except ({self.name}UnavailableError, {self.name}APIError):
                    logger.warning(f"{self.name} API недоступно, используется fallback")
                    return self._get_fallback_result(endpoint, params)
            
            def _get_fallback_result(self, endpoint: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
                """Fallback результат при недоступности API"""
                # TODO: Реализовать fallback логику (кеш, дефолтные значения и т.д.)
                return {{
                    "status": "fallback",
                    "message": f"{self.name} API unavailable",
                    "endpoint": endpoint,
                    "timestamp": "{{}}".format(__import__('datetime').datetime.now().isoformat())
                }}
        
        
        # Health Check функция
        async def check_{self.snake_name}_api_health() -> bool:
            """
            Health check для {self.name} API
            
            Returns:
                True если API доступно, False иначе
            """
            try:
                # TODO: Заменить на реальные настройки API
                # client = {self.name}Client(base_url="https://api.example.com", timeout=5)
                # response = await client.get("/health")
                # return "status" in response and response["status"] == "ok"
                logger.info(f"Health check для {self.name} API: ОК")
                return True
            except Exception as e:
                logger.error(f"Health check для {self.name} API failed: {{e}}")
                return False
        
        
        def register_{self.snake_name}_api_health_check():
            """Регистрирует health check в системе"""
            health_checker = get_health_checker()
            health_checker.register_check("{self.snake_name}_api", check_{self.snake_name}_api_health)
            logger.info(f"Health check для {self.name} API зарегистрирован")
        ''').strip()
    
    def generate_init_instructions(self) -> str:
        """Генерирует инструкции по интеграции"""
        service_name_lower = self.snake_name
        service_name = self.name
        
        return textwrap.dedent(f'''
        # 🚀 Инструкции по интеграции {service_name}
        
        ## 1. Регистрация в DI контейнере
        
        Добавьте в `src/core/di/modules/default.py`:
        
        ```python
        from core.{service_name_lower} import {service_name}Repository, register_{service_name_lower}_health_check
        # или для API:
        # from core.{service_name_lower} import {service_name}Client, register_{service_name_lower}_api_health_check
        
        PROVIDERS: Providers = [
            # ... существующие провайдеры
            aioinject.Scoped({service_name}Repository),
            # или для API:
            # aioinject.Scoped({service_name}Client),
        ]
        ```
        
        ## 2. Регистрация Health Check
        
        Добавьте в `src/app.py` в функцию `register_default_health_checks()`:
        
        ```python
        from core.{service_name_lower} import register_{service_name_lower}_health_check
        # или для API:
        # from core.{service_name_lower} import register_{service_name_lower}_api_health_check
        
        def register_default_health_checks():
            # ... существующие health checks
            register_{service_name_lower}_health_check()
            # или для API:
            # register_{service_name_lower}_api_health_check()
        ```
        
        ## 3. Настройка конфигурации
        
        Добавьте в `src/settings.py` если нужны настройки:
        
        ```python
        class {service_name}Settings(BaseSettings):
            api_url: str = "https://api.example.com"
            api_key: Optional[str] = None
            timeout: int = 30
            
            class Config:
                env_prefix = "{service_name.upper()}_"
        ```
        
        ## 4. Использование в коде
        
        ```python
        from core.{service_name_lower} import {service_name}Repository, {service_name}UnavailableError
        
        async def my_handler({service_name_lower}_repo: {service_name}Repository = Provide[{service_name}Repository]):
            try:
                # Основная операция
                result = await {service_name_lower}_repo.create({{"data": "example"}})
                return result
            except {service_name}UnavailableError:
                # Fallback операция
                return await {service_name_lower}_repo.create_with_fallback({{"data": "example"}})
        ```
        
        ## 5. TODO: Доработки
        
        - [ ] Замените `Any` типы на реальные
        - [ ] Реализуйте fallback логику
        - [ ] Настройте реальные health check URL
        - [ ] Добавьте кеширование если нужно
        - [ ] Настройте конфигурацию из переменных окружения
        - [ ] Добавьте юнит тесты
        
        ## 6. Мониторинг
        
        Health check будет доступен по адресу:
        - `/health/services/{service_name_lower}` - статус конкретного сервиса
        - `/health/detailed` - детальная информация
        ''').strip()
    
    def generate(self):
        """Генерирует все файлы для сервиса"""
        
        # Создаем директорию для сервиса
        service_dir = self.base_path / "src" / "core" / self.snake_name
        service_dir.mkdir(parents=True, exist_ok=True)
        
        # Генерируем основной код
        if self.service_type == "repository":
            code = self.generate_repository()
            filename = "repository.py"
        elif self.service_type == "api":
            code = self.generate_api_client()
            filename = "client.py"
        else:
            raise ValueError(f"Неподдерживаемый тип: {self.service_type}")
        
        # Записываем основной файл
        main_file = service_dir / filename
        main_file.write_text(code, encoding='utf-8')
        print(f"✅ Создан файл: {main_file}")
        
        # Создаем __init__.py
        init_file = service_dir / "__init__.py"
        if self.service_type == "repository":
            init_content = f'''"""
{self.name} модуль с resilience паттернами
"""

from .repository import (
    {self.name}Repository,
    {self.name}UnavailableError,
    check_{self.snake_name}_health,
    register_{self.snake_name}_health_check,
    {self.upper_snake_name}_RETRY_CONFIG,
    {self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG,
)

__all__ = [
    "{self.name}Repository",
    "{self.name}UnavailableError", 
    "check_{self.snake_name}_health",
    "register_{self.snake_name}_health_check",
    "{self.upper_snake_name}_RETRY_CONFIG",
    "{self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG",
]
'''
        else:
            init_content = f'''"""
{self.name} API модуль с resilience паттернами
"""

from .client import (
    {self.name}Client,
    {self.name}APIError,
    {self.name}UnavailableError,
    check_{self.snake_name}_api_health,
    register_{self.snake_name}_api_health_check,
    {self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG,
)

__all__ = [
    "{self.name}Client",
    "{self.name}APIError",
    "{self.name}UnavailableError",
    "check_{self.snake_name}_api_health", 
    "register_{self.snake_name}_api_health_check",
    "{self.upper_snake_name}_CIRCUIT_BREAKER_CONFIG",
]
'''
        
        init_file.write_text(init_content, encoding='utf-8')
        print(f"✅ Создан файл: {init_file}")
        
        # Создаем инструкции по интеграции
        instructions = self.generate_init_instructions()
        instructions_file = service_dir / "INTEGRATION.md"
        instructions_file.write_text(instructions, encoding='utf-8')
        print(f"✅ Создан файл: {instructions_file}")
        
        print(f"\n🎉 {self.name} {self.service_type} успешно сгенерирован!")
        print(f"📁 Местоположение: {service_dir}")
        print(f"📋 Инструкции по интеграции: {instructions_file}")


def main():
    parser = argparse.ArgumentParser(
        description="Генератор resilient сервисов для QuestCity Backend"
    )
    parser.add_argument(
        "--name", 
        required=True,
        help="Название сервиса (например: PaymentService, NotificationAPI)"
    )
    parser.add_argument(
        "--type",
        choices=["repository", "api"],
        required=True,
        help="Тип сервиса: repository или api"
    )
    parser.add_argument(
        "--base-path",
        type=Path,
        default=Path.cwd(),
        help="Базовый путь проекта (по умолчанию: текущая директория)"
    )
    
    args = parser.parse_args()
    
    # Проверяем что мы в правильной директории
    src_path = args.base_path / "src"
    if not src_path.exists():
        print(f"❌ Ошибка: директория {src_path} не найдена")
        print("Убедитесь что вы запускаете скрипт из корня backend проекта")
        return 1
    
    try:
        generator = ResilientServiceGenerator(args.name, args.type, args.base_path)
        generator.generate()
        
        print(f"\n📋 Следующие шаги:")
        print(f"1. Изучите файл INTEGRATION.md в созданной директории")
        print(f"2. Зарегистрируйте сервис в DI контейнере")
        print(f"3. Добавьте health check в app.py")
        print(f"4. Настройте конфигурацию в settings.py")
        print(f"5. Реализуйте TODO части в сгенерированном коде")
        
        return 0
        
    except Exception as e:
        print(f"❌ Ошибка генерации: {e}")
        return 1


if __name__ == "__main__":
    exit(main()) 