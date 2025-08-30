#!/usr/bin/env python3
"""
Скрипт для проверки доступных эндпоинтов
"""

import requests

BASE_URL = "http://localhost:8000"

def test_endpoints():
    """Тестируем различные эндпоинты"""
    
    endpoints = [
        "/",
        "/docs",
        "/v1",
        "/v1/quests",
        "/v1/quests/admin",
        "/v1/quests/admin/create",
        "/auth/login",
        "/health",
    ]
    
    print("🔍 Проверяем доступные эндпоинты:")
    print("=" * 50)
    
    for endpoint in endpoints:
        url = f"{BASE_URL}{endpoint}"
        try:
            response = requests.get(url, timeout=5)
            print(f"✅ {endpoint}: {response.status_code}")
            if response.status_code == 200:
                print(f"   Content-Type: {response.headers.get('content-type', 'N/A')}")
        except requests.exceptions.RequestException as e:
            print(f"❌ {endpoint}: {e}")

if __name__ == "__main__":
    test_endpoints()







