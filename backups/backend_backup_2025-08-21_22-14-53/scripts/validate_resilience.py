#!/usr/bin/env python3
"""
🔍 Валидатор resilience паттернов для QuestCity Backend

Автоматически проверяет что новые сервисы следуют resilience patterns:
- Retry механизм присутствует
- Circuit Breaker настроен
- Health Check реализован
- Exception classes созданы
- Graceful Degradation добавлена

Использование:
    python scripts/validate_resilience.py
    python scripts/validate_resilience.py --path src/core/payment
    python scripts/validate_resilience.py --strict  # Строгая проверка
"""

import argparse
import ast
import re
from pathlib import Path
from typing import List, Dict, Any, Set, Optional
from dataclasses import dataclass
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class ValidationResult:
    """Результат валидации"""
    file_path: Path
    has_retry: bool = False
    has_circuit_breaker: bool = False
    has_health_check: bool = False
    has_exception_class: bool = False
    has_graceful_degradation: bool = False
    has_logging: bool = False
    has_availability_check: bool = False
    issues: List[str] = None
    score: float = 0.0
    
    def __post_init__(self):
        if self.issues is None:
            self.issues = []
        self._calculate_score()
    
    def _calculate_score(self):
        """Рассчитать общий балл (0-100)"""
        total_checks = 7
        passed_checks = sum([
            self.has_retry,
            self.has_circuit_breaker,
            self.has_health_check,
            self.has_exception_class,
            self.has_graceful_degradation,
            self.has_logging,
            self.has_availability_check
        ])
        self.score = (passed_checks / total_checks) * 100


class ResilienceValidator:
    """Валидатор resilience паттернов"""
    
    RETRY_PATTERNS = [
        r'@retry_with_backoff',
        r'from.*retry.*import.*retry_with_backoff',
        r'RetryConfig'
    ]
    
    CIRCUIT_BREAKER_PATTERNS = [
        r'@circuit_breaker',
        r'from.*circuit_breaker.*import',
        r'CircuitBreakerConfig'
    ]
    
    HEALTH_CHECK_PATTERNS = [
        r'def.*check.*health.*\(',
        r'async def.*check.*health.*\(',
        r'health_checker\.register_check',
        r'get_health_checker'
    ]
    
    EXCEPTION_PATTERNS = [
        r'class.*UnavailableError.*Exception',
        r'class.*APIError.*Exception',
        r'raise.*UnavailableError'
    ]
    
    GRACEFUL_DEGRADATION_PATTERNS = [
        r'def.*with_fallback.*\(',
        r'async def.*with_fallback.*\(',
        r'except.*UnavailableError:',
        r'fallback.*result'
    ]
    
    LOGGING_PATTERNS = [
        r'import logging',
        r'logger\.info',
        r'logger\.warning',
        r'logger\.error'
    ]
    
    AVAILABILITY_CHECK_PATTERNS = [
        r'health_checker\.is_service_available',
        r'if not.*is_service_available',
        r'Service.*unavailable'
    ]
    
    def __init__(self, strict_mode: bool = False):
        self.strict_mode = strict_mode
    
    def validate_file(self, file_path: Path) -> ValidationResult:
        """Валидировать один файл"""
        result = ValidationResult(file_path=file_path)
        
        if not file_path.exists():
            result.issues.append(f"Файл не найден: {file_path}")
            return result
        
        try:
            content = file_path.read_text(encoding='utf-8')
            
            # Проверяем каждый паттерн
            result.has_retry = self._check_patterns(content, self.RETRY_PATTERNS)
            result.has_circuit_breaker = self._check_patterns(content, self.CIRCUIT_BREAKER_PATTERNS)
            result.has_health_check = self._check_patterns(content, self.HEALTH_CHECK_PATTERNS)
            result.has_exception_class = self._check_patterns(content, self.EXCEPTION_PATTERNS)
            result.has_graceful_degradation = self._check_patterns(content, self.GRACEFUL_DEGRADATION_PATTERNS)
            result.has_logging = self._check_patterns(content, self.LOGGING_PATTERNS)
            result.has_availability_check = self._check_patterns(content, self.AVAILABILITY_CHECK_PATTERNS)
            
            # Собираем issues
            if not result.has_retry:
                result.issues.append("❌ Отсутствует retry механизм (@retry_with_backoff)")
            
            if not result.has_circuit_breaker:
                result.issues.append("❌ Отсутствует Circuit Breaker (@circuit_breaker)")
            
            if not result.has_health_check:
                result.issues.append("❌ Отсутствует Health Check функция")
            
            if not result.has_exception_class:
                result.issues.append("❌ Отсутствуют Exception классы (UnavailableError/APIError)")
            
            if not result.has_graceful_degradation:
                result.issues.append("❌ Отсутствует Graceful Degradation (*_with_fallback методы)")
            
            if not result.has_logging:
                result.issues.append("❌ Отсутствует Logging")
            
            if not result.has_availability_check:
                result.issues.append("❌ Отсутствует проверка доступности сервиса")
            
            # Дополнительные проверки для strict mode
            if self.strict_mode:
                self._strict_validation(content, result)
            
            # Пересчитываем балл после всех проверок
            result._calculate_score()
                
        except Exception as e:
            result.issues.append(f"Ошибка чтения файла: {e}")
        
        return result
    
    def _check_patterns(self, content: str, patterns: List[str]) -> bool:
        """Проверить что хотя бы один паттерн найден"""
        for pattern in patterns:
            if re.search(pattern, content, re.IGNORECASE | re.MULTILINE):
                return True
        return False
    
    def _strict_validation(self, content: str, result: ValidationResult):
        """Дополнительные строгие проверки"""
        
        # Проверяем что есть конфигурация retry/circuit breaker
        if not re.search(r'.*_RETRY_CONFIG.*=.*RetryConfig', content):
            result.issues.append("⚠️ Строгая проверка: Отсутствует конфигурация RetryConfig")
        
        if not re.search(r'.*_CIRCUIT_BREAKER_CONFIG.*=.*CircuitBreakerConfig', content):
            result.issues.append("⚠️ Строгая проверка: Отсутствует конфигурация CircuitBreakerConfig")
        
        # Проверяем что есть регистрация health check
        if not re.search(r'def register.*health_check', content):
            result.issues.append("⚠️ Строгая проверка: Отсутствует функция регистрации health check")
        
        # Проверяем async/await правильность
        async_functions = re.findall(r'async def\s+(\w+)', content)
        for func_name in async_functions:
            if not re.search(rf'await.*{func_name}', content) and 'health' not in func_name.lower():
                result.issues.append(f"⚠️ Строгая проверка: async функция {func_name} может не использовать await")
    
    def validate_directory(self, directory: Path) -> List[ValidationResult]:
        """Валидировать все Python файлы в директории"""
        results = []
        
        # Находим все Python файлы (исключая __pycache__, .pyc и др.)
        python_files = list(directory.rglob("*.py"))
        python_files = [f for f in python_files if not any(part.startswith('.') or part == '__pycache__' for part in f.parts)]
        
        for file_path in python_files:
            # Пропускаем __init__.py и тестовые файлы если не строгий режим
            if not self.strict_mode:
                if file_path.name in ['__init__.py'] or 'test' in file_path.name.lower():
                    continue
            
            result = self.validate_file(file_path)
            results.append(result)
        
        return results
    
    def generate_report(self, results: List[ValidationResult]) -> str:
        """Генерировать отчет по результатам валидации"""
        if not results:
            return "📋 Файлы для валидации не найдены"
        
        total_files = len(results)
        passing_files = len([r for r in results if r.score >= 80])
        average_score = sum(r.score for r in results) / total_files
        
        report = [
            "# 🔍 Отчет валидации Resilience паттернов",
            "",
            f"**Дата:** {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"**Файлов проверено:** {total_files}",
            f"**Файлов прошло проверку (≥80%):** {passing_files} / {total_files}",
            f"**Средний балл:** {average_score:.1f}/100",
            "",
            "## 📊 Общий статус",
            ""
        ]
        
        if average_score >= 90:
            report.append("🟢 **ОТЛИЧНО** - Все resilience паттерны соблюдены")
        elif average_score >= 80:
            report.append("🟡 **ХОРОШО** - Большинство паттернов соблюдено, есть мелкие замечания")
        elif average_score >= 60:
            report.append("🟠 **УДОВЛЕТВОРИТЕЛЬНО** - Нужны улучшения")
        else:
            report.append("🔴 **КРИТИЧНО** - Много нарушений resilience паттернов")
        
        report.extend([
            "",
            "## 📋 Детальные результаты",
            ""
        ])
        
        # Сортируем по баллу (сначала худшие)
        results.sort(key=lambda r: r.score)
        
        for result in results:
            status_emoji = "✅" if result.score >= 80 else "⚠️" if result.score >= 60 else "❌"
            relative_path = result.file_path.relative_to(Path.cwd()) if result.file_path.is_absolute() else result.file_path
            
            report.extend([
                f"### {status_emoji} {relative_path}",
                f"**Балл:** {result.score:.1f}/100",
                ""
            ])
            
            if result.score >= 80:
                report.append("✅ Все основные resilience паттерны присутствуют")
            else:
                report.append("**Проблемы:**")
                for issue in result.issues:
                    report.append(f"- {issue}")
            
            # Показываем что есть хорошего
            good_things = []
            if result.has_retry:
                good_things.append("✅ Retry механизм")
            if result.has_circuit_breaker:
                good_things.append("✅ Circuit Breaker")
            if result.has_health_check:
                good_things.append("✅ Health Check")
            if result.has_exception_class:
                good_things.append("✅ Exception classes")
            if result.has_graceful_degradation:
                good_things.append("✅ Graceful Degradation")
            if result.has_logging:
                good_things.append("✅ Logging")
            if result.has_availability_check:
                good_things.append("✅ Availability Check")
            
            if good_things:
                report.append("")
                report.append("**Реализовано:**")
                for thing in good_things:
                    report.append(f"- {thing}")
            
            report.append("")
        
        # Рекомендации
        report.extend([
            "## 🚀 Рекомендации",
            "",
            "### Для автоматического исправления:",
            "```bash",
            "# Генерировать новый resilient сервис:",
            "python scripts/generate_resilient_service.py --name YourService --type repository",
            "",
            "# Или скопировать паттерны из существующих resilient сервисов:",
            "# - src/core/resilience/ (примеры паттернов)",
            "# - docs/AI_DEVELOPMENT_GUIDELINES.md (шаблоны)",
            "```",
            "",
            "### Минимальные требования для прохождения валидации:",
            "1. ✅ **Retry** декоратор на всех внешних вызовах",
            "2. ✅ **Circuit Breaker** для предотвращения каскадных сбоев",
            "3. ✅ **Health Check** функция и регистрация",
            "4. ✅ **Exception** классы для ошибок сервиса", 
            "5. ✅ **Graceful Degradation** (fallback методы)",
            "6. ✅ **Logging** для операций и ошибок",
            "7. ✅ **Availability Check** перед операциями",
            "",
            "### Дополнительные улучшения:",
            "- 🔧 Connection pooling для HTTP клиентов",
            "- 📊 Метрики для мониторинга",
            "- 🧪 Юнит тесты для resilience сценариев",
            "- 📚 Документация API/Repository",
            ""
        ])
        
        return "\n".join(report)


def main():
    parser = argparse.ArgumentParser(
        description="Валидатор resilience паттернов для QuestCity Backend"
    )
    parser.add_argument(
        "--path",
        type=Path,
        default=Path("questcity-backend/main/src/core"),
        help="Путь для валидации (по умолчанию: src/core)"
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Строгий режим валидации"
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Сохранить отчет в файл"
    )
    parser.add_argument(
        "--min-score",
        type=float,
        default=80.0,
        help="Минимальный балл для прохождения (по умолчанию: 80)"
    )
    
    args = parser.parse_args()
    
    if not args.path.exists():
        logger.error(f"Путь не найден: {args.path}")
        return 1
    
    validator = ResilienceValidator(strict_mode=args.strict)
    
    logger.info(f"🔍 Валидация resilience паттернов: {args.path}")
    logger.info(f"📊 Режим: {'Строгий' if args.strict else 'Стандартный'}")
    
    if args.path.is_file():
        results = [validator.validate_file(args.path)]
    else:
        results = validator.validate_directory(args.path)
    
    if not results:
        logger.warning("Файлы для валидации не найдены")
        return 0
    
    # Генерируем отчет
    report = validator.generate_report(results)
    
    # Выводим на экран
    print(report)
    
    # Сохраняем в файл если указан
    if args.output:
        args.output.write_text(report, encoding='utf-8')
        logger.info(f"💾 Отчет сохранен: {args.output}")
    
    # Проверяем прохождение валидации
    average_score = sum(r.score for r in results) / len(results)
    failed_files = [r for r in results if r.score < args.min_score]
    
    if failed_files:
        logger.error(f"❌ Валидация не пройдена! {len(failed_files)} файлов не соответствуют стандарту")
        logger.error(f"📊 Средний балл: {average_score:.1f} (требуется: {args.min_score})")
        return 1
    else:
        logger.info(f"✅ Валидация пройдена! Средний балл: {average_score:.1f}")
        return 0


if __name__ == "__main__":
    exit(main()) 