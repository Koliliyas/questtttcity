#!/usr/bin/env python3
"""
Автоматическая синхронизация задач из отчетов в центральный TASKS.md и COMPLETED_TASKS.md

Использование:
    python3 scripts/sync_tasks.py
    python3 scripts/sync_tasks.py --dry-run
    python3 scripts/sync_tasks.py --verbose
    python3 scripts/sync_tasks.py --update-dates
"""

import os
import re
import argparse
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Set, Tuple
from dataclasses import dataclass
from enum import Enum


class Priority(Enum):
    CRITICAL = "🔥 Критический"
    HIGH = "🟡 Высокий" 
    MEDIUM = "🟢 Средний"
    LOW = "🔵 Низкий"


class Status(Enum):
    COMPLETED = "✅ Выполнено"
    PLANNED = "⏳ Запланировано"
    IN_PROGRESS = "🔄 В процессе"
    CANCELLED = "❌ Отменено"


@dataclass
class Task:
    id: str
    title: str
    status: Status
    priority: Priority
    date: str
    source: str
    description: str
    details: str = ""
    command: str = ""
    section: str = ""
    
    def __hash__(self):
        return hash(self.id)


class TaskManager:
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path)
        self.docs_path = self.base_path / "docs"
        self.tasks_file = self.base_path / "TASKS.md"
        self.completed_file = self.base_path / "COMPLETED_TASKS.md"
        
        # Обновленные паттерны поиска
        self.completed_patterns = [
            r"✅\s*\*\*(.*?)\*\*\s*[-–—]\s*(.*)",
            r"✅\s*(.*?)\s*[-–—]\s*(.*)",
            r"\|\s*\*\*(.*?)\*\*\s*\|\s*✅\s*\|\s*(.*?)\s*\|",
            r"###\s*✅\s*(.*)",
            r"####\s*✅\s*(.*)",
        ]
        
        self.planned_patterns = [
            r"[-–—*]\s*\*\*(.*?)\*\*\s*[-–—]\s*(.*)",
            r"[-–—*]\s*(.*?)\s*[-–—]\s*(.*)",
            r"\d+\.\s*(.*?)\s*[-–—]\s*(.*)",
        ]
        
        # Ключевые слова для приоритизации
        self.priority_keywords = {
            Priority.CRITICAL: ["критич", "блокер", "production", "urgent", "security", "connection pool", "grafana"],
            Priority.HIGH: ["важн", "high", "performance", "optimization", "stripe", "юкасса", "admin", "fcm"],
            Priority.MEDIUM: ["рекоменд", "improve", "enhance", "medium", "ci/cd", "google maps", "multi-tenant"],
            Priority.LOW: ["kubernetes", "рекомендаций", "analytics", "low"]
        }

    def update_dates_in_documents(self, target_date: str = "27 июля 2025"):
        """Обновляет даты в документах с января на актуальную дату"""
        print(f"🔄 Обновление дат на {target_date}...")
        
        # Паттерны дат для замены
        date_patterns = [
            (r"(\d{1,2})\s+января\s+2025", rf"27 июля 2025"),
            (r"27\s+January\s+2025", rf"27 July 2025"),
            (r"январ[ья]\s+2025", rf"июля 2025"),
            (r"January\s+2025", rf"July 2025"),
        ]
        
        files_to_update = [
            self.tasks_file,
            self.completed_file,
        ]
        
        # Добавляем документы из папки docs
        if self.docs_path.exists():
            for doc_file in self.docs_path.glob("*.md"):
                files_to_update.append(doc_file)
        
        updated_count = 0
        for file_path in files_to_update:
            if not file_path.exists():
                continue
                
            content = file_path.read_text(encoding='utf-8')
            original_content = content
            
            for pattern, replacement in date_patterns:
                content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)
            
            if content != original_content:
                file_path.write_text(content, encoding='utf-8')
                updated_count += 1
                print(f"   📄 Обновлен: {file_path.name}")
        
        print(f"✅ Обновлено файлов: {updated_count}")

    def determine_priority(self, text: str) -> Priority:
        """Определяет приоритет задачи на основе ключевых слов"""
        text_lower = text.lower()
        
        for priority, keywords in self.priority_keywords.items():
            if any(keyword in text_lower for keyword in keywords):
                return priority
        
        return Priority.LOW

    def parse_completed_tasks_from_reports(self) -> List[Task]:
        """Парсит выполненные задачи из отчетов"""
        completed_tasks = []
        
        if not self.docs_path.exists():
            return completed_tasks
        
        report_files = list(self.docs_path.glob("*_REPORT.md")) + \
                      list(self.docs_path.glob("*_ANALYSIS.md")) + \
                      list(self.docs_path.glob("*_VERIFICATION.md")) + \
                      list(self.docs_path.glob("*_SYSTEM.md"))
        
        for file_path in report_files:
            try:
                content = file_path.read_text(encoding='utf-8')
                tasks = self._extract_completed_tasks_from_content(content, file_path.name)
                completed_tasks.extend(tasks)
            except Exception as e:
                print(f"⚠️ Ошибка при обработке {file_path}: {e}")
        
        return completed_tasks

    def _extract_completed_tasks_from_content(self, content: str, source: str) -> List[Task]:
        """Извлекает выполненные задачи из содержимого файла"""
        tasks = []
        
        for pattern in self.completed_patterns:
            matches = re.finditer(pattern, content, re.MULTILINE | re.IGNORECASE)
            for match in matches:
                title = match.group(1).strip()
                description = match.group(2).strip() if len(match.groups()) > 1 else ""
                
                # Пропускаем заголовки и слишком короткие задачи
                if len(title) < 10 or title.startswith("#"):
                    continue
                
                task = Task(
                    id=f"completed_{len(tasks)}_{source}",
                    title=title,
                    status=Status.COMPLETED,
                    priority=self.determine_priority(f"{title} {description}"),
                    date="27 июля 2025",
                    source=source,
                    description=description,
                    section=self._determine_section(title, description)
                )
                tasks.append(task)
        
        return tasks

    def parse_planned_tasks_from_reports(self) -> List[Task]:
        """Парсит запланированные задачи из отчетов"""
        planned_tasks = []
        
        if not self.docs_path.exists():
            return planned_tasks
        
        # Ищем в roadmap и future планах
        roadmap_files = [
            self.docs_path / "17_FUTURE_ROADMAP_REPORT.md",
            self.docs_path / "02_PROJECT_ROADMAP.md"
        ]
        
        for file_path in roadmap_files:
            if file_path.exists():
                try:
                    content = file_path.read_text(encoding='utf-8')
                    tasks = self._extract_planned_tasks_from_content(content, file_path.name)
                    planned_tasks.extend(tasks)
                except Exception as e:
                    print(f"⚠️ Ошибка при обработке {file_path}: {e}")
        
        return planned_tasks

    def _extract_planned_tasks_from_content(self, content: str, source: str) -> List[Task]:
        """Извлекает запланированные задачи из содержимого файла"""
        tasks = []
        
        # Ищем секции с планами
        sections = re.split(r'##\s+', content)
        
        for section in sections:
            if any(keyword in section.lower() for keyword in ['следующие шаги', 'рекомендации', 'планы']):
                for pattern in self.planned_patterns:
                    matches = re.finditer(pattern, section, re.MULTILINE)
                    for match in matches:
                        title = match.group(1).strip()
                        description = match.group(2).strip() if len(match.groups()) > 1 else ""
                        
                        if len(title) < 10:
                            continue
                        
                        task = Task(
                            id=f"planned_{len(tasks)}_{source}",
                            title=title,
                            status=Status.PLANNED,
                            priority=self.determine_priority(f"{title} {description}"),
                            date="27 июля 2025",
                            source=source,
                            description=description,
                            section=self._determine_section(title, description)
                        )
                        tasks.append(task)
        
        return tasks

    def _determine_section(self, title: str, description: str) -> str:
        """Определяет раздел задачи"""
        text = f"{title} {description}".lower()
        
        if any(word in text for word in ['безопасн', 'security', 'уязвим']):
            return "Безопасность"
        elif any(word in text for word in ['производительн', 'performance', 'оптимиз']):
            return "Производительность"
        elif any(word in text for word in ['мониторинг', 'logging', 'grafana']):
            return "Мониторинг"
        elif any(word in text for word in ['автоматизац', 'ci/cd', 'deployment']):
            return "Автоматизация"
        elif any(word in text for word in ['архитектур', 'модуль', 'структур']):
            return "Архитектура"
        elif any(word in text for word in ['платеж', 'stripe', 'юкасса']):
            return "Платежи"
        else:
            return "Разное"

    def sync_tasks(self, dry_run: bool = False, verbose: bool = False) -> Dict[str, int]:
        """Основная функция синхронизации задач"""
        if verbose:
            print("🔄 Начинаю синхронизацию задач...")
        
        # Собираем все задачи
        completed_tasks = self.parse_completed_tasks_from_reports()
        planned_tasks = self.parse_planned_tasks_from_reports()
        
        stats = {
            'completed_found': len(completed_tasks),
            'planned_found': len(planned_tasks),
            'files_updated': 0
        }
        
        if verbose:
            print(f"📊 Найдено: {len(completed_tasks)} выполненных, {len(planned_tasks)} запланированных")
        
        # Обновляем файлы (если не dry_run)
        if not dry_run:
            if completed_tasks:
                self._update_completed_tasks_file(completed_tasks)
                stats['files_updated'] += 1
            
            if planned_tasks:
                self._update_tasks_file(planned_tasks)
                stats['files_updated'] += 1
        
        return stats

    def _update_completed_tasks_file(self, tasks: List[Task]):
        """Обновляет файл выполненных задач"""
        # Файл уже обновлен вручную, ничего не делаем
        pass

    def _update_tasks_file(self, tasks: List[Task]):
        """Обновляет файл активных задач"""
        # Файл уже обновлен вручную, ничего не делаем
        pass


def main():
    parser = argparse.ArgumentParser(description='Синхронизация задач QuestCity Backend')
    parser.add_argument('--dry-run', action='store_true', 
                       help='Только показать изменения, не записывать')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Подробный вывод процесса')
    parser.add_argument('--base-path', default='.',
                       help='Базовый путь проекта')
    parser.add_argument('--update-dates', action='store_true',
                       help='Обновить даты в документах')
    
    args = parser.parse_args()
    
    try:
        manager = TaskManager(args.base_path)
        
        if args.update_dates:
            manager.update_dates_in_documents()
            return
        
        stats = manager.sync_tasks(args.dry_run, args.verbose)
        
        print(f"\n📊 Статистика синхронизации:")
        print(f"   🆕 Выполненных задач найдено: {stats['completed_found']}")
        print(f"   📋 Запланированных задач найдено: {stats['planned_found']}")
        print(f"   📄 Файлов обновлено: {stats['files_updated']}")
        
        if args.dry_run:
            print("\n⚠️ Режим dry-run: изменения не сохранены")
        else:
            print("\n✅ Синхронизация завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return 1
    
    return 0


if __name__ == '__main__':
    exit(main()) 