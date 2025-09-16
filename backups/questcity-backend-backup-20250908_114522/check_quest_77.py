#!/usr/bin/env python3
"""
Проверка квеста с ID 77 и его кодировки
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def check_quest_77():
    """Проверяем квест с ID 77 на проблемы с кодировкой"""
    
    # Получаем параметры подключения
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔍 Проверяем квест с ID 77 на проблемы с кодировкой")
    print(f"🔗 Подключение: {database_host}:{database_port}/{database_name}")
    print("=" * 60)
    
    try:
        # Подключаемся к базе данных
        conn = await asyncpg.connect(database_url)
        
        # Проверяем квест
        quest_query = """
        SELECT id, name, description, image, category_id, level, timeframe, 
               "group", cost, reward, pay_extra, is_subscription, vehicle_id,
               mentor_preference, auto_accrual, milage, place_id
        FROM quest 
        WHERE id = 77
        """
        
        quest_result = await conn.fetchrow(quest_query)
        
        if quest_result is None:
            print("❌ Квест с ID 77 не найден")
            return
        
        print(f"✅ Quest ID: {quest_result['id']}")
        print(f"✅ Quest Name: {quest_result['name']}")
        print(f"✅ Quest Description: {quest_result['description']}")
        print(f"✅ Quest Image: {quest_result['image']}")
        print(f"✅ Quest Mentor Preference: {quest_result['mentor_preference']}")
        
        # Проверяем на проблемы с кодировкой
        name = quest_result['name'] or ""
        description = quest_result['description'] or ""
        mentor_preference = quest_result['mentor_preference'] or ""
        
        print("\n🔍 Анализ кодировки:")
        print(f"  - Name length: {len(name)}")
        print(f"  - Description length: {len(description)}")
        print(f"  - Mentor preference length: {len(mentor_preference)}")
        
        # Проверяем на известные проблемы с кодировкой
        problematic_patterns = [
            'РІРІРµСЂРІРІРµСЂР°',
            'РІРІРµСЂРІРІРµСЂР°',
            'РІРІРµСЂРІРІРµСЂР°',
            'СЃРµСЂРІРІРµСЂР°',
            'РІРІРµСЂРІРІРµСЂР°'
        ]
        
        has_encoding_issues = False
        for pattern in problematic_patterns:
            if pattern in name or pattern in description or pattern in mentor_preference:
                print(f"  ❌ Найдена проблема с кодировкой: {pattern}")
                has_encoding_issues = True
        
        if has_encoding_issues:
            print("\n⚠️  ВНИМАНИЕ: Обнаружены проблемы с кодировкой!")
            print("   Это может вызывать проблемы при удалении квеста.")
            
            # Пытаемся исправить кодировку
            print("\n🔧 Попытка исправления кодировки:")
            try:
                # Пытаемся исправить кодировку Windows-1251 -> UTF-8
                fixed_name = name.encode('latin1').decode('utf-8', errors='ignore')
                fixed_description = description.encode('latin1').decode('utf-8', errors='ignore')
                fixed_mentor = mentor_preference.encode('latin1').decode('utf-8', errors='ignore')
                
                print(f"  - Fixed name: {fixed_name}")
                print(f"  - Fixed description: {fixed_description}")
                print(f"  - Fixed mentor preference: {fixed_mentor}")
                
            except Exception as e:
                print(f"  ❌ Не удалось исправить кодировку: {e}")
        else:
            print("  ✅ Проблем с кодировкой не обнаружено")
        
        # Проверяем связанные данные
        print("\n🔍 Проверяем связанные данные:")
        
        # Точки квеста
        points_query = """
        SELECT id, name_of_location, description, "order", type_id, tool_id, 
               file, is_divide, quest_id
        FROM point 
        WHERE quest_id = 77
        ORDER BY "order"
        """
        
        points_result = await conn.fetch(points_query)
        print(f"  - Points count: {len(points_result)}")
        
        for i, point in enumerate(points_result):
            point_name = point['name_of_location'] or ""
            point_desc = point['description'] or ""
            
            print(f"    Point {i+1}: {point_name}")
            if any(pattern in point_name or pattern in point_desc for pattern in problematic_patterns):
                print(f"      ❌ Проблема с кодировкой в точке {i+1}")
        
        # Мерч
        merch_query = """
        SELECT id, name, description, image, quest_id
        FROM merch 
        WHERE quest_id = 77
        """
        
        merch_result = await conn.fetch(merch_query)
        print(f"  - Merch count: {len(merch_result)}")
        
        # Отзывы
        reviews_query = """
        SELECT id, text, quest_id
        FROM review 
        WHERE quest_id = 77
        """
        
        reviews_result = await conn.fetch(reviews_query)
        print(f"  - Reviews count: {len(reviews_result)}")
        
        await conn.close()
        
        print("\n" + "=" * 60)
        if has_encoding_issues:
            print("⚠️  РЕКОМЕНДАЦИЯ: Исправьте кодировку квеста перед удалением")
            print("   Или попробуйте удалить квест через SQL напрямую")
        else:
            print("✅ Квест выглядит нормально, проблемы с удалением в другом месте")
            
    except Exception as e:
        print(f"❌ Ошибка при проверке: {e}")

if __name__ == "__main__":
    asyncio.run(check_quest_77())
