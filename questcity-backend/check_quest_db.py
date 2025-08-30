import asyncio
from src.db.dependencies import create_session
from src.db.models.quest.quest import Quest
from sqlalchemy import select

async def check_quest_db():
    async with create_session() as session:
        # Проверяем квест с ID 77
        result = await session.execute(select(Quest).where(Quest.id == 77))
        quest = result.scalar_one_or_none()
        
        if quest is None:
            print("❌ Квест с ID 77 не найден")
            return
        
        print(f"✅ Quest ID: {quest.id}")
        print(f"✅ Quest Name: {quest.name}")
        print(f"✅ Points count: {len(quest.points)}")
        
        for i, point in enumerate(quest.points):
            print(f"\n📍 Point {i}:")
            print(f"  - name_of_location: {point.name_of_location}")
            print(f"  - type_id: {point.type_id}")
            print(f"  - tool_id: {point.tool_id}")
            print(f"  - file: {point.file}")
            print(f"  - is_divide: {point.is_divide}")
            print(f"  - places count: {len(point.places)}")
            
            for j, place in enumerate(point.places):
                print(f"    🏠 Place {j}:")
                print(f"      - longitude: {place.longitude}")
                print(f"      - latitude: {place.latitude}")
                print(f"      - detections_radius: {place.detections_radius}")
                print(f"      - height: {place.height}")
                print(f"      - interaction_inaccuracy: {place.interaction_inaccuracy}")
                print(f"      - part: {place.part}")
                print(f"      - random_occurrence: {place.random_occurrence}")

if __name__ == "__main__":
    asyncio.run(check_quest_db())







