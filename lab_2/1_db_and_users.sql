-- Створення бази даних (використовуємо твоє ім'я для ідентифікації на перевірці)
CREATE DATABASE sports_club_rohalin_fedir;

-- УВАГА: Після виконання верхнього рядка, переключись на базу sports_club_rohalin_fedir у pgAdmin!
-- І вже в Query Tool нової бази виконай створення користувачів:

-- Створення адміністратора (повний доступ)
CREATE ROLE club_admin LOGIN PASSWORD 'admin123' SUPERUSER;

-- Створення модератора (наприклад, менеджер на рецепції - може додавати дані, але не змінювати структуру БД)
CREATE ROLE club_moderator LOGIN PASSWORD 'mod123';
GRANT CONNECT ON DATABASE sports_club_rohalin_fedir TO club_moderator;

-- Створення звичайного користувача (наприклад, клієнт в додатку - може тільки читати розклад)
CREATE ROLE club_user LOGIN PASSWORD 'user123';
GRANT CONNECT ON DATABASE sports_club_rohalin_fedir TO club_user;