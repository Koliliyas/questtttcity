#!/usr/bin/env python3
"""
Скрипт для получения нового токена админа
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def get_new_admin_token():
    """Получаем новый токен для админа"""
    try:
        login_data = {
            "login": "admin@questcity.com",
            "password": "Admin123!"
        }
        
        print("🔐 Получаем новый токен для админа...")
        response = requests.post(f"{BASE_URL}/api/v1/auth/login", data=login_data)
        
        if response.status_code == 200:
            result = response.json()
            token = result.get("accessToken")
            
            if token:
                # Сохраняем токен в файл
                with open('.admin_token', 'w') as f:
                    f.write(token)
                
                print(f"✅ Новый токен получен и сохранен в .admin_token")
                print(f"   Токен: {token[:20]}...")
                return token
            else:
                print("❌ Токен не найден в ответе")
                return None
        else:
            print(f"❌ Ошибка логина: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Ошибка при получении токена: {e}")
        return None

if __name__ == "__main__":
    get_new_admin_token()
