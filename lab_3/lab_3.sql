-- Лабораторна робота №3
-- Студента групи МІТ-31 Рогаліна Федора

-- ==========================================
-- ЧАСТИНА 1. ЛОГІЧНІ ОПЕРАТОРИ ТА БАЗОВІ УМОВИ
-- ==========================================

-- Запит 1. Отримати всі записи з таблиці Members (Клієнти)
SELECT * FROM Members;

-- Запит 2. Отримати тренерів, які спеціалізуються на 'Йога' або 'Кросфіт' (IN)
SELECT full_name, specialization FROM Trainers 
WHERE specialization IN ('Йога', 'Кросфіт');

-- Запит 3. Клієнти, чий телефон починається на '+38050' (LIKE)
SELECT full_name, phone FROM Members 
WHERE phone LIKE '+38050%';

-- Запит 4. Тренування, що мають місткість від 10 до 20 осіб (BETWEEN)
SELECT title, max_capacity FROM Workouts 
WHERE max_capacity BETWEEN 10 AND 20;

-- Запит 5. Абонементи, що не є 'Разовий' і коштують більше 1000 (AND, !=)
SELECT type, price FROM Memberships 
WHERE type != 'Разовий' AND price > 1000;


-- ==========================================
-- ЧАСТИНА 2. АГРЕГАТНІ ФУНКЦІЇ
-- ==========================================

-- Запит 6. Підрахувати загальну кількість клієнтів (COUNT)
SELECT COUNT(*) AS total_members FROM Members;

-- Запит 7. Знайти загальну суму прибутку від проданих абонементів (SUM)
SELECT SUM(price) AS total_revenue FROM Memberships;

-- Запит 8. Визначити середню вартість абонемента (AVG)
SELECT ROUND(AVG(price), 2) AS average_price FROM Memberships;

-- Запит 9. Знайти найдешевший абонемент (MIN)
SELECT MIN(price) AS min_price FROM Memberships;

-- Запит 10. Знайти тренування з найбільшою кількістю місць (MAX)
SELECT MAX(max_capacity) AS maximum_capacity FROM Workouts;


-- ==========================================
-- ЧАСТИНА 3. УСІ ТИПИ JOIN
-- ==========================================

-- Запит 11. INNER JOIN: Отримати імена клієнтів та типи їхніх абонементів
SELECT m.full_name, ms.type, ms.price 
FROM Members m
INNER JOIN Memberships ms ON m.member_id = ms.member_id;

-- Запит 12. LEFT JOIN: Всі тренери та їхні тренування (навіть якщо тренувань немає)
SELECT t.full_name, w.title 
FROM Trainers t
LEFT JOIN Workouts w ON t.trainer_id = w.trainer_id;

-- Запит 13. RIGHT JOIN: Всі записи на тренування і відповідні тренування
SELECT w.title, r.registration_date 
FROM Workout_Registrations r
RIGHT JOIN Workouts w ON r.workout_id = w.workout_id;

-- Запит 14. FULL JOIN: Об'єднання клієнтів і абонементів, щоб знайти клієнтів без абонементів і навпаки
SELECT m.full_name, ms.type 
FROM Members m
FULL JOIN Memberships ms ON m.member_id = ms.member_id;

-- Запит 15. CROSS JOIN: Всі можливі комбінації клієнтів та тренерів (декартовий добуток)
SELECT m.full_name AS member_name, t.full_name AS trainer_name 
FROM Members m
CROSS JOIN Trainers t;

-- Запит 16. SELF JOIN: Знайти тренерів з однаковою спеціалізацією
SELECT t1.full_name AS trainer_1, t2.full_name AS trainer_2, t1.specialization
FROM Trainers t1
JOIN Trainers t2 ON t1.specialization = t2.specialization AND t1.trainer_id != t2.trainer_id;


-- ==========================================
-- ЧАСТИНА 4. СКЛАДНІ ЗАПИТИ (ПІДЗАПИТИ У WHERE, IN, EXISTS)
-- ==========================================

-- Запит 17. Підзапит у WHERE: Клієнти, які купили найдорожчий абонемент
SELECT full_name FROM Members 
WHERE member_id IN (
    SELECT member_id FROM Memberships 
    WHERE price = (SELECT MAX(price) FROM Memberships)
);

-- Запит 18. NOT EXISTS: Знайти клієнтів, які жодного разу не записувалися на тренування
SELECT full_name FROM Members m
WHERE NOT EXISTS (
    SELECT 1 FROM Workout_Registrations r WHERE r.member_id = m.member_id
);

-- Запит 19. EXISTS: Знайти тренерів, які проводять хоча б одне тренування
SELECT full_name FROM Trainers t
WHERE EXISTS (
    SELECT 1 FROM Workouts w WHERE w.trainer_id = t.trainer_id
);

-- Запит 20. IN з підзапитом: Тренування, на які записався хоча б один клієнт
SELECT title FROM Workouts 
WHERE workout_id IN (SELECT workout_id FROM Workout_Registrations);

-- Запит 21. ГЛИБОКА ВКЛАДЕНІСТЬ (на високу оцінку): 
-- Імена клієнтів, які записані на тренування до тренера зі спеціалізацією "Кросфіт"
SELECT full_name FROM Members WHERE member_id IN (
    SELECT member_id FROM Workout_Registrations WHERE workout_id IN (
        SELECT workout_id FROM Workouts WHERE trainer_id IN (
            SELECT trainer_id FROM Trainers WHERE specialization = 'Кросфіт'
        )
    )
);

-- Запит 22. Підзапит у SELECT: Вивести назву тренування і загальну кількість тренувань поруч
SELECT title, (SELECT COUNT(*) FROM Workouts) AS total_workouts_count 
FROM Workouts;

-- Запит 23. Клієнти, які витратили на абонементи більше середньої вартості всіх абонементів
SELECT full_name FROM Members 
WHERE member_id IN (
    SELECT member_id FROM Memberships GROUP BY member_id HAVING SUM(price) > (
        SELECT AVG(price) FROM Memberships
    )
);


-- ==========================================
-- ЧАСТИНА 5. ОПЕРАЦІЇ НАД МНОЖИНАМИ
-- ==========================================

-- Запит 24. UNION: Отримати єдиний список імен усіх людей у клубі (клієнти + тренери)
SELECT full_name, 'Клієнт' AS role FROM Members
UNION
SELECT full_name, 'Тренер' AS role FROM Trainers;

-- Запит 25. INTERSECT: Ідентифікатори клієнтів, які купили абонемент І водночас записалися на тренування
SELECT member_id FROM Memberships
INTERSECT
SELECT member_id FROM Workout_Registrations;

-- Запит 26. EXCEPT: Ідентифікатори клієнтів, які зареєстровані в системі, АЛЕ НЕ купували абонемент
SELECT member_id FROM Members
EXCEPT
SELECT member_id FROM Memberships;


-- ==========================================
-- ЧАСТИНА 6. COMMON TABLE EXPRESSIONS (CTE)
-- ==========================================

-- Запит 27. Просте CTE: Список активних тренувань (з місткістю > 5)
WITH PopularWorkouts AS (
    SELECT workout_id, title FROM Workouts WHERE max_capacity > 5
)
SELECT * FROM PopularWorkouts;

-- Запит 28. CTE для агрегації: Кількість покупок кожного клієнта
WITH MemberPurchases AS (
    SELECT member_id, COUNT(*) as purchase_count FROM Memberships GROUP BY member_id
)
SELECT m.full_name, mp.purchase_count 
FROM Members m JOIN MemberPurchases mp ON m.member_id = mp.member_id;

-- Запит 29. Кілька CTE: Знаходження найприбутковішого клієнта
WITH ClientSpending AS (
    SELECT member_id, SUM(price) as total_spent FROM Memberships GROUP BY member_id
),
MaxSpending AS (
    SELECT MAX(total_spent) as top_spend FROM ClientSpending
)
SELECT m.full_name, cs.total_spent
FROM ClientSpending cs
JOIN Members m ON cs.member_id = m.member_id
JOIN MaxSpending ms ON cs.total_spent = ms.top_spend;

-- Запит 30. Підрахунок кількості записів на кожне тренування з використанням CTE
WITH RegCounts AS (
    SELECT workout_id, COUNT(member_id) as current_occupancy 
    FROM Workout_Registrations GROUP BY workout_id
)
SELECT w.title, w.max_capacity, COALESCE(rc.current_occupancy, 0) as registered
FROM Workouts w
LEFT JOIN RegCounts rc ON w.workout_id = rc.workout_id;

-- Запит 31. CTE для знаходження відсотка заповненості тренування
WITH OccupancyStats AS (
    SELECT w.title, w.max_capacity, COUNT(r.member_id) as attendees
    FROM Workouts w
    LEFT JOIN Workout_Registrations r ON w.workout_id = r.workout_id
    GROUP BY w.workout_id, w.title, w.max_capacity
)
SELECT title, ROUND((attendees::numeric / max_capacity::numeric) * 100, 2) AS fill_percentage
FROM OccupancyStats;


-- ==========================================
-- ЧАСТИНА 7. ВІКОННІ ФУНКЦІЇ (WINDOW FUNCTIONS)
-- ==========================================

-- Запит 32. ROW_NUMBER: Пронумерувати клієнтів за датою реєстрації
SELECT full_name, join_date,
ROW_NUMBER() OVER (ORDER BY join_date) as registration_queue
FROM Members;

-- Запит 33. RANK: Ранжування абонементів за вартістю від найдорожчого
SELECT type, price,
RANK() OVER (ORDER BY price DESC) as price_rank
FROM Memberships;

-- Запит 34. DENSE_RANK: Ранжування вартості (без пропусків у нумерації при однакових значеннях)
SELECT type, price,
DENSE_RANK() OVER (ORDER BY price DESC) as dense_price_rank
FROM Memberships;

-- Запит 35. SUM OVER (Running Total): Наростаючий підсумок прибутку за датою старту абонемента
SELECT start_date, price,
SUM(price) OVER (ORDER BY start_date) as running_total
FROM Memberships;

-- Запит 36. AVG OVER PARTITION BY: Порівняння вартості абонемента із середньою вартістю абонементів такого ж типу
SELECT type, price,
ROUND(AVG(price) OVER (PARTITION BY type), 2) as avg_price_for_type,
price - AVG(price) OVER (PARTITION BY type) as diff_from_avg
FROM Memberships;


-- ==========================================
-- ЧАСТИНА 8. КОМПЛЕКСНІ ЗАПИТИ З РІЗНИМИ КОНСТРУКЦІЯМИ (для макс. балу)
-- ==========================================

-- Запит 37. З'єднання + CTE + Віконна функція: ТОП-3 найдорожчих покупок клієнтів з іменами
WITH RankedPurchases AS (
    SELECT m.full_name, ms.price, ms.type,
    ROW_NUMBER() OVER(ORDER BY ms.price DESC) as rn
    FROM Members m JOIN Memberships ms ON m.member_id = ms.member_id
)
SELECT full_name, price, type FROM RankedPurchases WHERE rn <= 3;

-- Запит 38. Знайти тренерів, до яких ходить більше клієнтів, ніж у середньому до тренера
WITH TrainerAttendees AS (
    SELECT w.trainer_id, COUNT(wr.member_id) as total_attendees
    FROM Workouts w
    JOIN Workout_Registrations wr ON w.workout_id = wr.workout_id
    GROUP BY w.trainer_id
),
AvgAttendees AS (
    SELECT AVG(total_attendees) as avg_att FROM TrainerAttendees
)
SELECT t.full_name, ta.total_attendees 
FROM TrainerAttendees ta
JOIN Trainers t ON ta.trainer_id = t.trainer_id
CROSS JOIN AvgAttendees aa
WHERE ta.total_attendees > aa.avg_att;

-- Запит 39. Групування з HAVING + JOIN + Підзапит: Клієнти, які відвідали тренування певного тренера більше 1 разу
SELECT m.full_name, COUNT(wr.registration_id) as visits
FROM Members m
JOIN Workout_Registrations wr ON m.member_id = wr.member_id
WHERE wr.workout_id IN (SELECT workout_id FROM Workouts WHERE trainer_id = 1)
GROUP BY m.full_name
HAVING COUNT(wr.registration_id) > 1;

-- Запит 40. Мега-запит (CTE + Віконна + JOIN + Підзапит): Детальний профіль активності клубу
-- Показує ім'я клієнта, загальну суму його покупок, і його відносний ранг серед клієнтів
WITH ClientTotals AS (
    SELECT member_id, COALESCE(SUM(price), 0) as total_spent
    FROM Memberships GROUP BY member_id
),
ClientRanks AS (
    SELECT member_id, total_spent,
    RANK() OVER(ORDER BY total_spent DESC) as spend_rank
    FROM ClientTotals
)
SELECT m.full_name, cr.total_spent, cr.spend_rank,
(SELECT COUNT(*) FROM Workout_Registrations wr WHERE wr.member_id = m.member_id) as workouts_attended
FROM Members m
JOIN ClientRanks cr ON m.member_id = cr.member_id
ORDER BY cr.spend_rank;


-- ==========================================
-- ВИСНОВКИ
-- ==========================================
-- Під час виконання лабораторної роботи №3 було закріплено теоретичні знання 
-- та набуто практичних навичок роботи зі складними SQL-запитами у PostgreSQL. 
-- Було розроблено 40 запитів, що повною мірою покривають вимоги до фільтрації 
-- даних, використання агрегатних функцій, усіх типів об'єднань (JOIN), а також 
-- використання вкладених підзапитів, CTE та аналітичних віконних функцій. 
-- Написані скрипти готові для використання у бізнес-аналітиці спортивного клубу.