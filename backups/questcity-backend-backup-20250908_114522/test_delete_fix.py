#!/usr/bin/env python3
"""
Тест исправления удаления квеста
"""

import requests
import json

def test_delete_endpoint():
    """Тест эндпоинта удаления квеста"""
    
    # Конфигурация
    BASE_URL = "http://localhost:8000/api/v1"
    QUEST_ID = 77  # ID квеста из логов
    
    # URL для удаления квеста
    url = f"{BASE_URL}/quests/admin/delete/{QUEST_ID}"
    
    print(f"🧪 Тестируем исправление удаления квеста {QUEST_ID}")
    print(f"📡 URL: {url}")
    print("=" * 60)
    
    try:
        # Отправляем DELETE запрос без авторизации (для проверки 401 вместо 404)
        response = requests.delete(url)
        
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 401:
            print("✅ SUCCESS: Got 401 (Unauthorized) - API endpoint exists and works!")
            print("   The route conflict has been fixed!")
            print("   Now the admin delete endpoint is accessible.")
            return True
        elif response.status_code == 404:
            print("❌ ERROR: Still getting 404 - route conflict not fixed")
            return False
        elif response.status_code == 200:
            print("✅ SUCCESS: Got 200 - quest deleted successfully!")
            return True
        else:
            print(f"⚠️  UNEXPECTED: Got {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Cannot connect to server")
        return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_route_conflict():
    """Тест на конфликт маршрутов"""
    
    BASE_URL = "http://localhost:8000/api/v1"
    QUEST_ID = 77
    
    # Тест общего маршрута (должен вернуть 404, так как мы его закомментировали)
    general_url = f"{BASE_URL}/quests/{QUEST_ID}"
    
    print(f"\n🧪 Тестируем общий маршрут (должен быть 404)")
    print(f"📡 URL: {general_url}")
    
    try:
        response = requests.delete(general_url)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 404:
            print("✅ SUCCESS: General route returns 404 (as expected)")
        else:
            print(f"⚠️  UNEXPECTED: General route returns {response.status_code}")
            
    except Exception as e:
        print(f"❌ ERROR: {e}")

if __name__ == "__main__":
    print("Testing quest deletion fix...")
    print("=" * 60)
    
    # Тест основного эндпоинта
    success = test_delete_endpoint()
    
    # Тест конфликта маршрутов
    test_route_conflict()
    
    print("\n" + "=" * 60)
    if success:
        print("🎉 SUCCESS: Quest deletion should now work!")
        print("   The route conflict has been resolved.")
    else:
        print("❌ FAILED: Quest deletion still has issues.")
