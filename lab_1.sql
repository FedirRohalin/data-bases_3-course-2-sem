-- 1. Створення таблиці "Ресторани"
CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    rating NUMERIC(2, 1)
);

-- 2. Створення таблиці "Меню"
CREATE TABLE menus (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE
);

-- 3. Створення таблиці "Замовлення"
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE
);

-- Додаємо ресторани
INSERT INTO restaurants (name, address, rating) VALUES 
('Pizza Lviv', 'вул. Франка, 12', 4.8),
('Sushi Master', 'пр. Свободи, 45', 4.5),
('Burger Bar', 'вул. Шевченка, 8', 4.2);

-- Додаємо страви в меню (вважаємо, що Pizza Lviv отримала id=1, Sushi Master=2, Burger Bar=3)
INSERT INTO menus (restaurant_id, item_name, price) VALUES 
(1, 'Піца Маргарита', 250.00),
(1, 'Піца Карбонара', 280.00),
(2, 'Рол Філадельфія', 320.00),
(3, 'Чізбургер', 180.00),
(3, 'Картопля фрі', 80.00);

-- Додаємо замовлення
INSERT INTO orders (restaurant_id, customer_name, total_amount) VALUES 
(1, 'Олександр', 530.00),
(2, 'Марія', 320.00),
(3, 'Іван', 260.00);

-- 1. Переглянути всі ресторани:
SELECT * FROM restaurants;

-- 2. Переглянути меню конкретного ресторану (наприклад, Pizza Lviv, id=1):
SELECT item_name, price FROM menus WHERE restaurant_id = 1;

-- 3. Вибірка з об'єднанням таблиць (JOIN) - показує замовлення разом із назвою ресторану:
SELECT o.order_id, o.customer_name, r.name AS restaurant_name, o.total_amount 
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id;

UPDATE menus 
SET price = 195.00 
WHERE item_name = 'Чізбургер';

DELETE FROM orders 
WHERE customer_name = 'Іван';

DELETE FROM restaurants WHERE restaurant_id = 2;