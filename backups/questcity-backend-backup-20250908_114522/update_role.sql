-- Обновление роли пользователя на ADMIN (role = 2)
UPDATE "user" 
SET role = 2 
WHERE email = 'testuser@questcity.com';

-- Проверка результата
SELECT username, email, role, is_active, is_verified 
FROM "user" 
WHERE email = 'testuser@questcity.com'; 