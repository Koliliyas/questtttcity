#!/usr/bin/env python3
"""
Скрипт для тестирования паролей админа
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def test_admin_passwords():
    """Тестируем разные пароли для админа"""
    
    passwords_to_test = [
        "admin123",
        "admin",
        "password",
        "password123",
        "123456",
        "admin@questcity.com",
        "questcity",
        "questcity123"
    ]
    
    print("🔐 Тестируем пароли для admin@questcity.com")
    print("=" * 50)
    
    for password in passwords_to_test:
        try:
            login_data = {
                "login": "admin@questcity.com",
                "password": password
            }
            
            response = requests.post(f"{BASE_URL}/api/v1/auth/login", data=login_data)
            
            if response.status_code == 200:
                result = response.json()
                token = result.get("accessToken")
                if token:
                    print(f"✅ Успех! Пароль: {password}")
                    print(f"   Токен: {token[:20]}...")
                    
                    # Сохраняем токен админа
                    with open('.admin_token', 'w') as f:
                        f.write(token)
                    print(f"   Токен сохранен в .admin_token")
                    return token
            else:
                print(f"❌ Пароль '{password}' не подходит")
                
        except Exception as e:
            print(f"❌ Ошибка с паролем '{password}': {e}")
    
    print("❌ Ни один пароль не подошел")
    return None

if __name__ == "__main__":
    test_admin_passwords()
