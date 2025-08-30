import asyncio
import psycopg2
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Прямое подключение через psycopg2
def test_psycopg2():
    print("🔍 Тестируем psycopg2...")
    try:
        conn = psycopg2.connect(
            host='localhost',
            database='questcity',
            user='postgres',
            password='postgres'
        )
        cursor = conn.cursor()
        
        # Проверяем таблицу activity
        cursor.execute("SELECT * FROM activity WHERE id = 1")
        row = cursor.fetchone()
        print(f"  psycopg2 результат: {row}")
        
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"  psycopg2 ошибка: {e}")

# SQLAlchemy подключение
def test_sqlalchemy():
    print("🔍 Тестируем SQLAlchemy...")
    try:
        engine = create_engine('postgresql://postgres:postgres@localhost/questcity')
        Session = sessionmaker(bind=engine)
        session = Session()
        
        # Прямой SQL запрос
        result = session.execute(text("SELECT * FROM activity WHERE id = 1"))
        row = result.fetchone()
        print(f"  SQLAlchemy SQL результат: {row}")
        
        session.close()
    except Exception as e:
        print(f"  SQLAlchemy ошибка: {e}")

# Тестируем модель Activity
def test_activity_model():
    print("🔍 Тестируем модель Activity...")
    try:
        from src.db.models.quest.point import Activity
        from src.db.engine import get_async_engine
        
        print(f"  Модель: {Activity}")
        print(f"  Таблица: {Activity.__tablename__}")
        print(f"  Колонки: {[c.name for c in Activity.__table__.columns]}")
        
    except Exception as e:
        print(f"  Модель Activity ошибка: {e}")

if __name__ == "__main__":
    print("🚀 Тестируем доступ к таблице activity...")
    test_psycopg2()
    test_sqlalchemy()
    test_activity_model()












