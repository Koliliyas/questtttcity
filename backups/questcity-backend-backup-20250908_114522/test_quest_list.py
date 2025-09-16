#!/usr/bin/env python3
"""
Скрипт для получения списка всех квестов
"""

import asyncio
import os
import sys
import requests
import json

# Добавляем путь к модулям проекта
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

async def test_quest_list():
    """Получаем список всех квестов"""
    
    # Базовый URL API
    base_url = "http://localhost:8000/api/v1"
    
    print("🧪 Получение списка всех квестов")
    print(f"📡 API URL: {base_url}")
    
    try:
        # Получаем список всех квестов
        print(f"\n🔍 Получаем список всех квестов...")
        get_response = requests.get(f"{base_url}/quests/")
        
        print(f"📊 Статус получения квестов: {get_response.status_code}")
        
        if get_response.status_code == 200:
            quests_data = get_response.json()
            print(f"✅ Квесты получены успешно!")
            print(f"📊 Количество квестов: {len(quests_data)}")
            
            # Ищем квест ID 61
            quest_61 = None
            for quest in quests_data:
                if quest.get('id') == 61:
                    quest_61 = quest
                    break
            
            if quest_61:
                print(f"\n🎯 Найден квест ID 61:")
                print(f"  - ID: {quest_61.get('id')}")
                print(f"  - Title: {quest_61.get('title')}")
                print(f"  - Description: {quest_61.get('description')}")
                print(f"  - Mentor Preference: {quest_61.get('mentorPreference')}")
                print(f"  - Merch List: {quest_61.get('merchList', [])}")
            else:
                print(f"\n❌ Квест ID 61 не найден в списке")
                
            # Показываем первые 3 квеста
            print(f"\n📋 Первые 3 квеста:")
            for i, quest in enumerate(quests_data[:3]):
                print(f"  {i+1}. ID: {quest.get('id')}, Title: '{quest.get('title')}'")
        else:
            print(f"❌ Ошибка получения квестов: {get_response.status_code}")
            print(f"📄 Ответ: {get_response.text}")
            
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_quest_list())
















