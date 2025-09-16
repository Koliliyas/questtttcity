import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def check_quest_sql():
    # Получаем параметры подключения из переменных окружения
    database_user = os.getenv("DATABASE_USERNAME", "postgres")
    database_password = os.getenv("DATABASE_PASSWORD", "postgres")
    database_host = os.getenv("DATABASE_HOST", "localhost")
    database_port = os.getenv("DATABASE_PORT", "5432")
    database_name = os.getenv("DATABASE_NAME", "questcity_db")
    
    database_url = f"postgresql://{database_user}:{database_password}@{database_host}:{database_port}/{database_name}"
    
    print(f"🔗 Подключаемся к базе данных: {database_host}:{database_port}/{database_name}")
    
    try:
        # Подключаемся к базе данных
        conn = await asyncpg.connect(database_url)
        
        # Проверяем квест
        quest_query = """
        SELECT id, name, description, image, category_id, level, timeframe, 
               "group", cost, reward, pay_extra, is_subscription, vehicle_id
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
        
        # Проверяем точки квеста
        points_query = """
        SELECT id, name_of_location, description, "order", type_id, tool_id, 
               file, is_divide, quest_id
        FROM point 
        WHERE quest_id = 77
        ORDER BY "order"
        """
        
        points_result = await conn.fetch(points_query)
        
        print(f"✅ Points count: {len(points_result)}")
        
        for i, point in enumerate(points_result):
            print(f"\n📍 Point {i}:")
            print(f"  - ID: {point['id']}")
            print(f"  - name_of_location: {point['name_of_location']}")
            print(f"  - description: {point['description']}")
            print(f"  - order: {point['order']}")
            print(f"  - type_id: {point['type_id']}")
            print(f"  - tool_id: {point['tool_id']}")
            print(f"  - file: {point['file']}")
            print(f"  - is_divide: {point['is_divide']}")
            
            # Проверяем места для этой точки
            places_query = """
            SELECT id, longitude, latitude, detections_radius, height, 
                   interaction_inaccuracy, part, random_occurrence, point_id
            FROM place_settings 
            WHERE point_id = $1
            """
            
            places_result = await conn.fetch(places_query, point['id'])
            
            print(f"  - places count: {len(places_result)}")
            
            for j, place in enumerate(places_result):
                print(f"    🏠 Place {j}:")
                print(f"      - ID: {place['id']}")
                print(f"      - longitude: {place['longitude']}")
                print(f"      - latitude: {place['latitude']}")
                print(f"      - detections_radius: {place['detections_radius']}")
                print(f"      - height: {place['height']}")
                print(f"      - interaction_inaccuracy: {place['interaction_inaccuracy']}")
                print(f"      - part: {place['part']}")
                print(f"      - random_occurrence: {place['random_occurrence']}")
        
        await conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при подключении к базе данных: {e}")

if __name__ == "__main__":
    asyncio.run(check_quest_sql())
