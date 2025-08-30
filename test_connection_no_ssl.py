#!/usr/bin/env python3
"""
Упрощенный тест подключения к QuestCity без SSL
"""

import requests
import socket
from datetime import datetime

def test_api_connection():
    """Тест подключения к API"""
    print("🚀 Тест подключения к QuestCity API (без SSL)")
    print("=" * 50)
    print(f"📅 Время теста: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Тест 1: API через IP
    print("🔌 Тест 1: API через IP адрес")
    try:
        response = requests.get("http://176.98.177.16/api/v1/health/", timeout=10)
        print(f"✅ Статус: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   📊 Ответ: {data}")
        return True
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def test_domain_connection():
    """Тест подключения к домену"""
    print("\n🌐 Тест 2: Подключение к домену")
    try:
        response = requests.get("http://questcity.ru/api/v1/health/", timeout=10, allow_redirects=False)
        print(f"✅ Статус: {response.status_code}")
        if response.status_code == 301:
            print(f"   🔄 Редирект на: {response.headers.get('Location', 'Неизвестно')}")
            print("   ⚠️  Домен перенаправляет на HTTPS")
            return False
        elif response.status_code == 200:
            data = response.json()
            print(f"   📊 Ответ: {data}")
            return True
        else:
            print(f"   📄 Ответ: {response.text[:200]}...")
            return False
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False

def main():
    # Тест API через IP
    api_works = test_api_connection()
    
    # Тест домена
    domain_works = test_domain_connection()
    
    print("\n📊 ИТОГОВАЯ ОЦЕНКА")
    print("=" * 50)
    
    if api_works:
        print("✅ API работает через IP адрес")
    else:
        print("❌ API не работает через IP")
    
    if domain_works:
        print("✅ Домен работает по HTTP")
    else:
        print("⚠️  Домен перенаправляет на HTTPS")
    
    print("\n🔧 РЕКОМЕНДАЦИИ:")
    if api_works and not domain_works:
        print("   1. API работает, но домен перенаправляет на HTTPS")
        print("   2. Для временного решения используйте IP адрес: http://176.98.177.16/api/v1/")
        print("   3. Проверьте настройки в панели Timeweb")
        print("   4. Возможно, нужно отключить принудительный редирект на HTTPS")
    elif api_works and domain_works:
        print("   1. Все работает отлично!")
        print("   2. Можно использовать домен: http://questcity.ru/api/v1/")
    else:
        print("   1. Есть проблемы с подключением")
        print("   2. Проверьте статус сервера")

if __name__ == "__main__":
    main()

