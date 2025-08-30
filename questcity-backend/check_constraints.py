#!/usr/bin/env python3
"""
Скрипт для проверки внешних ключей в базе данных
"""

import asyncio
import sys
import os

# Добавляем путь к src
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from src.db.dependencies import create_session
from sqlalchemy import text

async def check_foreign_key_constraints():
    """Проверяет внешние ключи для таблиц, связанных с quest"""
    
    async with create_session() as session:
        try:
            # SQL запрос для проверки внешних ключей
            query = text("""
                SELECT 
                    tc.table_name, 
                    tc.constraint_name, 
                    tc.constraint_type,
                    kcu.column_name,
                    ccu.table_name AS foreign_table_name,
                    ccu.column_name AS foreign_column_name,
                    rc.delete_rule,
                    rc.update_rule
                FROM 
                    information_schema.table_constraints AS tc 
                    JOIN information_schema.key_column_usage AS kcu
                      ON tc.constraint_name = kcu.constraint_name
                      AND tc.table_schema = kcu.table_schema
                    JOIN information_schema.constraint_column_usage AS ccu
                      ON ccu.constraint_name = tc.constraint_name
                      AND ccu.table_schema = tc.table_schema
                    JOIN information_schema.referential_constraints AS rc
                      ON tc.constraint_name = rc.constraint_name
                WHERE tc.constraint_type = 'FOREIGN KEY' 
                    AND tc.table_name IN ('merch', 'point', 'review')
                    AND ccu.table_name = 'quest'
                ORDER BY tc.table_name;
            """)
            
            result = await session.execute(query)
            rows = result.fetchall()
            
            print("🔍 Проверка внешних ключей для таблиц, связанных с quest:")
            print("=" * 80)
            
            if not rows:
                print("❌ Не найдено внешних ключей для таблиц merch, point, review")
                return False
            
            cascade_count = 0
            for row in rows:
                table_name = row[0]
                constraint_name = row[1]
                column_name = row[3]
                foreign_table = row[4]
                foreign_column = row[5]
                delete_rule = row[6]
                update_rule = row[7]
                
                status = "✅ CASCADE" if delete_rule == "CASCADE" else "❌ NO ACTION"
                if delete_rule == "CASCADE":
                    cascade_count += 1
                
                print(f"📋 Таблица: {table_name}")
                print(f"   Ограничение: {constraint_name}")
                print(f"   Колонка: {column_name} -> {foreign_table}.{foreign_column}")
                print(f"   Удаление: {status} ({delete_rule})")
                print(f"   Обновление: {update_rule}")
                print("-" * 40)
            
            print(f"\n📊 Итого: {cascade_count}/{len(rows)} таблиц с каскадным удалением")
            
            if cascade_count == len(rows):
                print("🎉 Все внешние ключи настроены правильно!")
                return True
            else:
                print("⚠️  Некоторые внешние ключи не имеют каскадного удаления")
                print("💡 Выполните скрипт fix_cascade_delete.sql для исправления")
                return False
                
        except Exception as e:
            print(f"❌ Ошибка при проверке ограничений: {e}")
            return False

if __name__ == "__main__":
    print("🔍 Запуск проверки внешних ключей...")
    success = asyncio.run(check_foreign_key_constraints())
    
    if success:
        print("\n✅ Проверка завершена успешно!")
    else:
        print("\n❌ Проверка выявила проблемы!")
    
    print("🏁 Готово.")








