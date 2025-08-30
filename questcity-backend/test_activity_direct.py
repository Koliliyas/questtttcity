import asyncio
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.orm import sessionmaker

def test_activity_table():
    print("🔍 Тестируем таблицу activity напрямую...")
    try:
        # Подключаемся к базе
        engine = create_engine('postgresql://postgres:postgres@localhost/questcity')
        
        # Проверяем структуру таблицы
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        print(f"  Все таблицы в базе: {tables}")
        
        # Проверяем схему таблицы activity
        if 'activity' in tables:
            columns = inspector.get_columns('activity')
            print(f"  Колонки таблицы activity: {[col['name'] for col in columns]}")
            
            # Проверяем данные
            with engine.connect() as conn:
                result = conn.execute(text("SELECT * FROM activity WHERE id = 1"))
                row = result.fetchone()
                print(f"  SQL запрос результат: {row}")
                
                # Проверяем все записи
                result = conn.execute(text("SELECT * FROM activity"))
                all_rows = result.fetchall()
                print(f"  Все записи в activity: {all_rows}")
        else:
            print("  ❌ Таблица 'activity' НЕ НАЙДЕНА!")
            
            # Ищем похожие таблицы
            similar_tables = [t for t in tables if 'activity' in t.lower() or 'type' in t.lower()]
            print(f"  Похожие таблицы: {similar_tables}")
            
    except Exception as e:
        print(f"  Ошибка: {e}")

def test_activity_model():
    print("🔍 Тестируем модель Activity...")
    try:
        from src.db.models.quest.point import Activity
        
        print(f"  Модель: {Activity}")
        print(f"  Таблица: {Activity.__tablename__}")
        print(f"  Схема: {Activity.__table__.schema}")
        print(f"  Полное имя: {Activity.__table__.fullname}")
        print(f"  Колонки: {[c.name for c in Activity.__table__.columns]}")
        
        # Проверяем, есть ли проблемы с импортом
        print(f"  Модуль: {Activity.__module__}")
        print(f"  Класс: {Activity.__class__}")
        
    except Exception as e:
        print(f"  Ошибка модели: {e}")

if __name__ == "__main__":
    print("🚀 Тестируем таблицу activity...")
    test_activity_table()
    test_activity_model()
















