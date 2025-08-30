#!/usr/bin/env python3
"""
Скрипт для проверки доступных инструментов
"""

import requests

BASE_URL = "http://localhost:8000"

def get_admin_token():
    """Получаем токен администратора"""
    try:
        with open('.admin_token', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        print("❌ Файл .admin_token не найден!")
        return None

def test_tools():
    """Проверяем доступные инструменты"""
    
    token = get_admin_token()
    if not token:
        print("❌ Не удалось получить токен администратора")
        return
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    try:
        # Пробуем получить список инструментов
        response = requests.get(f"{BASE_URL}/api/v1/quests/tools", headers=headers)
        
        print(f"📡 Ответ сервера:")
        print(f"  - Status Code: {response.status_code}")
        
        if response.status_code == 200:
            tools = response.json()
            print(f"  - Tools: {tools}")
        else:
            print(f"  - Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Исключение: {e}")

if __name__ == "__main__":
    test_tools()
