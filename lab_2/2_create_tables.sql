CREATE TABLE Members (
    member_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    join_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Trainers (
    trainer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    specialization VARCHAR(100)
);

CREATE TABLE Memberships (
    membership_id SERIAL PRIMARY KEY,
    member_id INT REFERENCES Members(member_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- Наприклад: Місячний, Річний, Разовий
    price NUMERIC(10, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE Workouts (
    workout_id SERIAL PRIMARY KEY,
    trainer_id INT REFERENCES Trainers(trainer_id) ON DELETE SET NULL,
    title VARCHAR(100) NOT NULL,
    workout_date TIMESTAMP NOT NULL,
    max_capacity INT NOT NULL
);

CREATE TABLE Workout_Registrations (
    registration_id SERIAL PRIMARY KEY,
    workout_id INT REFERENCES Workouts(workout_id) ON DELETE CASCADE,
    member_id INT REFERENCES Members(member_id) ON DELETE CASCADE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workout_id, member_id) -- Клієнт не може записатися двічі на одне тренування
);

-- Надаємо права ролям на щойно створені таблиці
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO club_moderator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO club_user;