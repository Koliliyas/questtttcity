#!/usr/bin/env python3
"""
Простой тест для проверки исправления удаления квеста
"""

import requests
import json

def test_delete_quest():
    """Тест удаления квеста через API"""
    
    # Конфигурация
    BASE_URL = "http://localhost:8000/api/v1"
    QUEST_ID = 48  # ID квеста для удаления
    
    # URL для удаления квеста
    url = f"{BASE_URL}/quests/admin/delete/{QUEST_ID}"
    
    print(f"Testing quest deletion for ID: {QUEST_ID}")
    print(f"URL: {url}")
    
    try:
        # Отправляем DELETE запрос без авторизации (для проверки ошибки)
        response = requests.delete(url)
        
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 401:
            print("SUCCESS: Got 401 (Unauthorized) - API endpoint exists")
            return True
        elif response.status_code == 500:
            print("ERROR: Got 500 (Server Error) - There's still an issue")
            return False
        else:
            print(f"UNEXPECTED: Got {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("ERROR: Cannot connect to server")
        return False
    except Exception as e:
        print(f"ERROR: {e}")
        return False

if __name__ == "__main__":
    print("Running simple delete test...")
    success = test_delete_quest()
    
    if success:
        print("Test completed successfully!")
    else:
        print("Test failed!")
    
    print("Done.")



