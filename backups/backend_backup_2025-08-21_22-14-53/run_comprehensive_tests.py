#!/usr/bin/env python3
"""
Скрипт для автоматизации запуска comprehensive integration тестов QuestCity Backend API.

Покрывает:
- CRUD операции всех справочников
- Валидацию данных и error scenarios
- Регрессионные тесты
- Performance тесты

Использование:
    python run_comprehensive_tests.py              # Все тесты
    python run_comprehensive_tests.py --quick      # Только основные CRUD тесты
    python run_comprehensive_tests.py --regression # Только регрессионные тесты
"""

import subprocess
import sys
import os
import argparse
from typing import List


def check_prerequisites() -> bool:
    """Проверяет предварительные требования для запуска тестов."""
    print("🔍 Проверка предварительных требований...")
    
    # Проверяем что backend запущен
    try:
        import requests
        response = requests.get("http://localhost:8000/api/v1/health/", timeout=5)
        if response.status_code == 200:
            print("✅ Backend сервер доступен")
        else:
            print("❌ Backend сервер недоступен")
            return False
    except Exception as e:
        print(f"❌ Backend сервер недоступен: {e}")
        return False
    
    # Проверяем наличие токена администратора
    if os.path.exists(".admin_token"):
        print("✅ Токен администратора найден")
    else:
        print("❌ Токен администратора не найден. Запустите: ./quick_start.sh")
        return False
    
    return True


def run_pytest_command(args: List[str]) -> int:
    """Запускает pytest с указанными аргументами."""
    cmd = ["poetry", "run", "pytest"] + args
    
    print(f"🧪 Запуск: {' '.join(cmd)}")
    print("=" * 60)
    
    try:
        result = subprocess.run(cmd, cwd=".", capture_output=False)
        return result.returncode
    except Exception as e:
        print(f"❌ Ошибка запуска тестов: {e}")
        return 1


def run_all_tests() -> int:
    """Запускает все comprehensive тесты."""
    print("🚀 Запуск ВСЕХ comprehensive integration тестов")
    
    args = [
        "tests/",
        "-v",
        "--tb=short",
        "--color=yes",
        "-x"  # Остановиться на первой ошибке
    ]
    
    return run_pytest_command(args)


def run_quick_tests() -> int:
    """Запускает только основные CRUD тесты."""
    print("⚡ Запуск быстрых CRUD тестов")
    
    args = [
        "tests/test_quest_references_crud.py",
        "-v",
        "--tb=short", 
        "--color=yes",
        "-k", "test_get_ or test_create_.*_success"  # Только GET и успешные CREATE тесты
    ]
    
    return run_pytest_command(args)


def run_regression_tests() -> int:
    """Запускает только регрессионные тесты."""
    print("🔄 Запуск регрессионных тестов")
    
    args = [
        "tests/",
        "-v",
        "--tb=short",
        "--color=yes", 
        "-k", "regression or TestRegressionScenarios"
    ]
    
    return run_pytest_command(args)


def run_validation_tests() -> int:
    """Запускает только тесты валидации."""
    print("✅ Запуск тестов валидации данных")
    
    args = [
        "tests/",
        "-v",
        "--tb=short",
        "--color=yes",
        "-k", "validation or TestDataValidationErrors"
    ]
    
    return run_pytest_command(args)


def run_performance_tests() -> int:
    """Запускает только performance тесты."""
    print("📊 Запуск performance тестов")
    
    args = [
        "tests/test_error_scenarios.py::TestPerformanceAndLimits",
        "-v",
        "--tb=short",
        "--color=yes"
    ]
    
    return run_pytest_command(args)


def generate_test_report() -> int:
    """Генерирует подробный отчёт о тестировании."""
    print("📋 Генерация подробного отчёта тестирования")
    
    args = [
        "tests/",
        "-v",
        "--tb=long",
        "--color=yes",
        "--durations=10"  # Показать 10 самых медленных тестов
    ]
    
    return run_pytest_command(args)


def main():
    """Главная функция."""
    parser = argparse.ArgumentParser(
        description="Comprehensive Integration Tests для QuestCity Backend API"
    )
    
    parser.add_argument(
        "--quick", 
        action="store_true",
        help="Запустить только основные CRUD тесты"
    )
    
    parser.add_argument(
        "--regression",
        action="store_true", 
        help="Запустить только регрессионные тесты"
    )
    
    parser.add_argument(
        "--validation",
        action="store_true",
        help="Запустить только тесты валидации"
    )
    
    parser.add_argument(
        "--performance",
        action="store_true",
        help="Запустить только performance тесты"
    )
    
    parser.add_argument(
        "--report",
        action="store_true",
        help="Сгенерировать подробный отчёт"
    )
    
    parser.add_argument(
        "--skip-check",
        action="store_true",
        help="Пропустить проверку предварительных требований"
    )
    
    args = parser.parse_args()
    
    print("=" * 60)
    print("🧪 COMPREHENSIVE INTEGRATION TESTS - QuestCity Backend API")
    print("=" * 60)
    
    # Проверка предварительных требований
    if not args.skip_check:
        if not check_prerequisites():
            print("\n❌ Предварительные требования не выполнены!")
            print("Запустите: ./quick_start.sh")
            return 1
        print()
    
    # Выбор типа тестов
    if args.quick:
        return run_quick_tests()
    elif args.regression:
        return run_regression_tests() 
    elif args.validation:
        return run_validation_tests()
    elif args.performance:
        return run_performance_tests()
    elif args.report:
        return generate_test_report()
    else:
        return run_all_tests()


if __name__ == "__main__":
    try:
        exit_code = main()
        
        if exit_code == 0:
            print("\n🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!")
        else:
            print(f"\n❌ Тесты завершились с ошибками (код: {exit_code})")
        
        sys.exit(exit_code)
        
    except KeyboardInterrupt:
        print("\n⚠️ Тестирование прервано пользователем")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 Критическая ошибка: {e}")
        sys.exit(1) 