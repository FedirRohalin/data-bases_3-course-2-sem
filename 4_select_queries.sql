-- 1. Вибірка всіх даних із певної таблиці
SELECT * FROM Members;

-- 2. Які унікальні значення є в певному стовпці? (DISTINCT)
-- Наприклад, які існують унікальні спеціалізації тренерів
SELECT DISTINCT specialization FROM Trainers;
	
-- 3. Скільки записів відповідає певній умові? (WHERE + COUNT)
-- Скільки абонементів коштують більше 2000 грн
SELECT COUNT(*) AS expensive_memberships FROM Memberships WHERE price > 2000;

-- 4. Сортування (ORDER BY)
-- Вивести розклад тренувань від найближчого до найпізнішого
SELECT title, workout_date FROM Workouts ORDER BY workout_date ASC;

-- 5. Які максимальні та мінімальні значення певного параметра? (MIN, MAX)
-- Найдешевший та найдорожчий проданий абонемент
SELECT MIN(price) AS min_price, MAX(price) AS max_price FROM Memberships;

-- 6. Яка загальна сума всіх транзакцій? (SUM)
-- Рахуємо загальний дохід від продажу абонементів
SELECT SUM(price) AS total_revenue FROM Memberships;

-- 7. Об'єднання таблиць (JOIN)
-- Виводимо хто з клієнтів на яке тренування записався
SELECT m.full_name, w.title, w.workout_date 
FROM Workout_Registrations wr
JOIN Members m ON wr.member_id = m.member_id
JOIN Workouts w ON wr.workout_id = w.workout_id;

-- 8. Групування (GROUP BY + HAVING)
-- Знайти клієнтів, які витратили на абонементи загалом більше 2000 грн
SELECT m.full_name, SUM(ms.price) AS total_spent
FROM Members m
JOIN Memberships ms ON m.member_id = ms.member_id
GROUP BY m.full_name
HAVING SUM(ms.price) > 2000;

-- 9. Яка середня кількість замовлень (абонементів) на клієнта? (AVG)
-- Використовуємо підзапит: спочатку рахуємо кількість для кожного, потім беремо середнє
SELECT ROUND(AVG(memberships_count), 2) AS avg_memberships_per_client
FROM (
    SELECT member_id, COUNT(membership_id) AS memberships_count
    FROM Memberships
    GROUP BY member_id
) AS subquery;