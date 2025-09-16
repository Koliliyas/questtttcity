#!/usr/bin/env python3
"""
QuestCity Backend - Базовый пользователь (устаревший)

ВНИМАНИЕ: Этот файл устарел и оставлен для обратной совместимости.
Используйте новый скрипт: scripts/create_admin.py

Для создания администратора выполните:
    python scripts/create_admin.py --interactive
    
Или с переменными окружения:
    ADMIN_USERNAME=admin ADMIN_EMAIL=admin@questcity.com python scripts/create_admin.py
"""

import asyncio
import os
import sys
import warnings
from pathlib import Path

# Предупреждение об устаревшем файле
warnings.warn(
    "create_base_user.py устарел. Используйте scripts/create_admin.py",
    DeprecationWarning,
    stacklevel=2
)

print("⚠️  create_base_user.py устарел!")
print("📍 Используйте новый скрипт: scripts/create_admin.py")
print("💡 Примеры:")
print("   python scripts/create_admin.py --interactive")
print("   python scripts/create_admin.py --username admin --email admin@questcity.com")
print("   python scripts/create_admin.py --generate-password")

# Добавляем путь к новому скрипту
scripts_path = Path(__file__).parent / "scripts"
sys.path.insert(0, str(scripts_path))

try:
    # Импортируем и запускаем новый скрипт
    from create_admin import main as create_admin_main
    
    print("\n🔄 Перенаправляем на новый скрипт...")
    
    # Устанавливаем значения по умолчанию для совместимости
    os.environ.setdefault('ADMIN_USERNAME', 'user')
    os.environ.setdefault('ADMIN_EMAIL', 'questcity-test@yandex.ru')  
    os.environ.setdefault('ADMIN_FIRST_NAME', 'admin')
    os.environ.setdefault('ADMIN_LAST_NAME', 'admin')
    os.environ.setdefault('ADMIN_PASSWORD', 'stringD#3')  # Старый пароль для совместимости
    
    # Запускаем новый скрипт
    asyncio.run(create_admin_main())
    
except ImportError as e:
    print(f"❌ Ошибка импорта нового скрипта: {e}")
    print("📁 Убедитесь что файл scripts/create_admin.py существует")
    sys.exit(1)
except Exception as e:
    print(f"❌ Ошибка выполнения: {e}")
    sys.exit(1)