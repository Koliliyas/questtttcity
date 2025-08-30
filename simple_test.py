#!/usr/bin/env python3
"""
Простой тест доступности сервера
"""
import requests

def test_server():
    """Тестирует доступность сервера"""
    print("🔧 ТЕСТ ДОСТУПНОСТИ СЕРВЕРА")
    print("=" * 80)
    
    # Тест HTTP
    print("\n📋 Тест HTTP")
    try:
        response = requests.get("http://questcity.ru/api/v1/health", timeout=10)
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка HTTP: {e}")
    
    # Тест HTTPS
    print("\n📋 Тест HTTPS")
    try:
        response = requests.get("https://questcity.ru/api/v1/health", timeout=10)
        print(f"  📊 Статус: {response.status_code}")
        print(f"  📄 Ответ: {response.text}")
    except Exception as e:
        print(f"  ❌ Ошибка HTTPS: {e}")

if __name__ == "__main__":
    test_server()
