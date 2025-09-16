-- Скрипт для добавления каскадного удаления в существующую базу данных
-- Выполните этот скрипт для исправления проблемы с удалением квестов

-- 1. Удаляем существующие внешние ключи
ALTER TABLE merch DROP CONSTRAINT IF EXISTS merch_quest_id_fkey;
ALTER TABLE point DROP CONSTRAINT IF EXISTS point_quest_id_fkey;
ALTER TABLE review DROP CONSTRAINT IF EXISTS review_quest_id_fkey;

-- 2. Добавляем новые внешние ключи с каскадным удалением
ALTER TABLE merch ADD CONSTRAINT merch_quest_id_fkey 
    FOREIGN KEY (quest_id) REFERENCES quest(id) ON DELETE CASCADE;

ALTER TABLE point ADD CONSTRAINT point_quest_id_fkey 
    FOREIGN KEY (quest_id) REFERENCES quest(id) ON DELETE CASCADE;

ALTER TABLE review ADD CONSTRAINT review_quest_id_fkey 
    FOREIGN KEY (quest_id) REFERENCES quest(id) ON DELETE CASCADE;

-- Проверяем, что ограничения созданы
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
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

















