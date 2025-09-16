#!/usr/bin/env python3
"""
Скрипт для отладки логина
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def debug_login():
    """Отлаживаем процесс логина"""
    try:
        login_data = {
            "login": "testuser@questcity.com",
            "password": "password123"
        }
        
        print("🔐 Отладка логина...")
        print(f"URL: {BASE_URL}/api/v1/auth/login")
        print(f"Данные: {login_data}")
        
        response = requests.post(f"{BASE_URL}/api/v1/auth/login", data=login_data)
        
        print(f"Статус: {response.status_code}")
        print(f"Заголовки: {dict(response.headers)}")
        print(f"Текст ответа: {response.text}")
        
        if response.status_code == 200:
            try:
                result = response.json()
                print(f"JSON ответ: {json.dumps(result, indent=2)}")
            except:
                print("Не удалось распарсить JSON")
        else:
            try:
                error = response.json()
                print(f"JSON ошибка: {json.dumps(error, indent=2)}")
            except:
                print("Не удалось распарсить JSON ошибки")
            
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    debug_login()
