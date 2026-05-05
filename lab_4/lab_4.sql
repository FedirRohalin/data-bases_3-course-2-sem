-- 1. Створюємо власний тип даних
CREATE TYPE membership_status AS ENUM ('активний', 'завершений', 'заморожений');

-- 2. Додаємо нову колонку в таблицю Memberships і ставимо значення за замовчуванням
ALTER TABLE Memberships 
ADD COLUMN status membership_status DEFAULT 'активний';


CREATE OR REPLACE FUNCTION get_available_spots(p_workout_id INT) 
RETURNS INT AS $$
DECLARE
    v_max_capacity INT;
    v_registered INT;
    v_available INT;
BEGIN
    -- Отримуємо максимальну кількість місць
    SELECT max_capacity INTO v_max_capacity 
    FROM Workouts WHERE workout_id = p_workout_id;

    -- Отримуємо кількість вже зареєстрованих клієнтів
    SELECT COUNT(*) INTO v_registered 
    FROM Workout_Registrations WHERE workout_id = p_workout_id;

    -- Обчислюємо вільні місця
    v_available := v_max_capacity - v_registered;
    
    RETURN v_available;
END;
$$ LANGUAGE plpgsql;


-- 1. Створюємо таблицю для логів
CREATE TABLE membership_log (
    log_id SERIAL PRIMARY KEY,
    membership_id INT,
    operation VARCHAR(10),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Створюємо функцію для тригера логування
CREATE OR REPLACE FUNCTION log_membership_changes() 
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO membership_log (membership_id, operation) VALUES (OLD.membership_id, 'DELETE');
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO membership_log (membership_id, operation) VALUES (NEW.membership_id, 'UPDATE');
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO membership_log (membership_id, operation) VALUES (NEW.membership_id, 'INSERT');
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 3. Прив'язуємо тригер до таблиці Memberships
CREATE TRIGGER track_membership_changes
AFTER INSERT OR UPDATE OR DELETE ON Memberships
FOR EACH ROW
EXECUTE FUNCTION log_membership_changes();


-- 1. Додаємо колонку для кешування кількості учасників
ALTER TABLE Workouts ADD COLUMN current_enrolled INT DEFAULT 0;

-- 2. Оновлюємо вже існуючі дані (щоб не було нулів для старих записів)
UPDATE Workouts w
SET current_enrolled = (
    SELECT COUNT(*) FROM Workout_Registrations wr WHERE wr.workout_id = w.workout_id
);

-- 3. Створюємо функцію тригера для автооновлення
CREATE OR REPLACE FUNCTION update_enrolled_count() 
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE Workouts SET current_enrolled = current_enrolled + 1 WHERE workout_id = NEW.workout_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE Workouts SET current_enrolled = current_enrolled - 1 WHERE workout_id = OLD.workout_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 4. Прив'язуємо тригер до таблиці реєстрацій
CREATE TRIGGER trigger_update_enrolled
AFTER INSERT OR DELETE ON Workout_Registrations
FOR EACH ROW
EXECUTE FUNCTION update_enrolled_count();


-- ТЕСТ 1: Перевірка роботи функції
-- Перевіряємо вільні місця на тренування з id = 1
SELECT title, max_capacity, get_available_spots(1) AS available_spots 
FROM Workouts WHERE workout_id = 1;

-- ТЕСТ 2: Перевірка тригера автооновлення
-- Додаємо новий запис на тренування 1 для клієнта 3
INSERT INTO Workout_Registrations (workout_id, member_id) VALUES (1, 3);
-- Дивимось, чи збільшилась колонка current_enrolled у таблиці Workouts
SELECT title, max_capacity, current_enrolled FROM Workouts WHERE workout_id = 1;

-- ТЕСТ 3: Перевірка тригера логування та нового типу ENUM
-- Змінюємо статус абонемента на "заморожений"
UPDATE Memberships SET status = 'заморожений' WHERE membership_id = 1;
-- Перевіряємо, чи з'явився запис про це у логах
SELECT * FROM membership_log;


