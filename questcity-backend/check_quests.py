#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import get_db
from app.models.quest import Quest
from app.models.category import Category

def check_database():
    try:
        db = next(get_db())
        
        # Проверяем квесты
        quests = db.query(Quest).all()
        print(f"📊 Всего квестов в базе: {len(quests)}")
        
        if quests:
            print("\n🔍 Первые 5 квестов:")
            for i, quest in enumerate(quests[:5]):
                print(f"  {i+1}. ID: {quest.id}, Название: {quest.title}")
        else:
            print("❌ Квестов в базе данных нет!")
        
        # Проверяем категории
        categories = db.query(Category).all()
        print(f"\n📊 Всего категорий в базе: {len(categories)}")
        
        if categories:
            print("\n🔍 Категории:")
            for i, category in enumerate(categories):
                print(f"  {i+1}. ID: {category.id}, Название: {category.name}")
        else:
            print("❌ Категорий в базе данных нет!")
            
    except Exception as e:
        print(f"❌ Ошибка при проверке базы данных: {e}")

if __name__ == "__main__":
    check_database()
