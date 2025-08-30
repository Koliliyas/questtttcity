#!/usr/bin/env python3
"""
Скрипт для тестирования квеста ID 61 с merchandise данными
"""

import asyncio
import os
import sys
import requests
import json

# Добавляем путь к модулям проекта
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

async def test_quest_61():
    """Тестируем квест ID 61 с merchandise данными"""
    
    # Базовый URL API
    base_url = "http://localhost:8000/api/v1"
    
    print("🧪 Тестирование квеста ID 61 с merchandise данными")
    print(f"📡 API URL: {base_url}")
    
    try:
        # 1. Получаем квест ID 61 без авторизации (публичный endpoint)
        print(f"\n🔍 Получаем квест ID 61...")
        get_response = requests.get(f"{base_url}/quests/61")
        
        print(f"📊 Статус получения квеста: {get_response.status_code}")
        
        if get_response.status_code == 200:
            quest_data = get_response.json()
            print(f"✅ Квест получен успешно!")
            print(f"📊 Данные квеста:")
            print(f"  - ID: {quest_data.get('id')}")
            print(f"  - Name: {quest_data.get('title')}")
            print(f"  - Mentor Preference: {quest_data.get('mentorPreference')}")
            print(f"  - Merch List Length: {len(quest_data.get('merchList', []))}")
            
            if quest_data.get('merchList'):
                merch = quest_data['merchList'][0]
                print(f"  - Merch Description: {merch.get('description')}")
                print(f"  - Merch Price: {merch.get('price')}")
                print(f"  - Merch Image: {merch.get('image', '')[:50]}...")
            else:
                print(f"  - Merch List: ПУСТОЙ!")
                
            # Выводим полный JSON для анализа
            print(f"\n📄 Полный JSON ответ:")
            print(json.dumps(quest_data, indent=2, ensure_ascii=False))
        else:
            print(f"❌ Ошибка получения квеста: {get_response.status_code}")
            print(f"📄 Ответ: {get_response.text}")
            
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_quest_61())







