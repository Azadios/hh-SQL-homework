-- task1
CREATE TABLE applicant
(
    applicant_id        serial  primary key,
    applicant_name      text    not null
);

CREATE TABLE cv
(
    cv_id                   serial      primary key,
    last_changed_at         timestamp   not null default now(),
    position_name           text        not null,
    applicant_id            integer     not null references applicant (applicant_id),
    desired_compensation    integer
);

CREATE TABLE employer
(
    employer_id     serial  primary key,
    employer_name   text    not null,
    area_id         integer not null
);

CREATE TABLE vacancy
(
    vacancy_id          serial      primary key,
    created_at          timestamp   not null default now(),
    position_name       text        not null,
    employer_id         integer     not null references employer (employer_id),
    compensation_from   integer,
    compensation_to     integer,
    compensation_gross  boolean     default true
);

CREATE TABLE response
(
    response_id     serial      primary key,
    created_at      timestamp   not null default now(),
    vacancy_id      integer     not null references vacancy (vacancy_id),
    cv_id           integer     not null references cv (cv_id),
    is_open         boolean     default true
);

-- task2
INSERT INTO applicant (applicant_name)
VALUES  ('Абдулов Азад'),
        ('Агапова Юлия'),
        ('Бриллиантов Кирилл'),
        ('Быстрова Мария'),
        ('Васильев Александр'),
        ('Васянин Дмитрий'),
        ('Вепринцев Борис'),
        ('Владимир Сургуч'),
        ('Гаптрахманов Роберт'),
        ('Голованов Юрий'),
        ('Долженков Максим'),
        ('Дубров Павел'),
        ('Зиякаев Артур'),
        ('Злотников Николай'),
        ('Икищели Михаил'),
        ('Ильин Иван'),
        ('Кальянов Никита'),
        ('Каргина Ксения');

INSERT INTO cv (position_name, applicant_id, desired_compensation)
VALUES  ('Senior заполнитель sql таблиц', 1, null),
        ('Тестировщик', 2, 30000),
        ('Разработчик Java', 3, 9000), -- Java compensations over 9000
        ('Тестировщик', 4, 45000),
        ('Разработчик C#', 5, 70000),
        ('Аналитик', 6, 70000),
        ('Тестировщик', 7, 40000),
        ('Разработчик Swift', 8, 80000),
        ('Разработчик brainfuck', 9, 300000),
        ('Разработчик на русском языке', 10, 30000),
        ('Тестировщик', 11, 50000),
        ('Разработчик Java', 12, 130000),
        ('Рьяный задаватель вопросов', 13, 0),
        ('Уборщик жуков из высоконагруженных систем', 14, 27000),
        ('Разработчик Python', 15, 75000),
        ('Аналитик', 16, 45000),
        ('Разработчик PHP', 17, 60000),
        ('Devops', 18, 1000000);

INSERT INTO employer (employer_name, area_id)
VALUES  ('hh.ru', 1),
        ('Яндекс', 1),
        ('Facebook', 2),
        ('Amazon', 2),
        ('Apple', 2),
        ('Netflix', 2),
        ('Google', 2),
        ('Ozon', 1),
        ('МТС', 1),
        ('Tesla', 2),
        ('SpaceX', 3),
        ('Blue Origin', 3);

INSERT INTO vacancy (position_name, employer_id, compensation_from, compensation_to, compensation_gross)
VALUES  ('Senior заполнитель sql таблиц', 1, 0, 0, true),
        ('Тестировщик', 1, 30000, null, false),
        ('Тестировщик', 2, null, null, true),
        ('Разработчик C#', 2, 60000, 100000, false),
        ('Аналитик', 2, null, null, true),
        ('Тестировщик', 3, null, null, true),
        ('Разработчик Swift', 3, 70000, 120000, true),
        ('Тестировщик', 4, null, null, true),
        ('Разработчик Java', 5, 300000, null, false),
        ('Разработчик Python', 6, 250000, 500000, false),
        ('Аналитик', 7, 250000, null, false),
        ('Разработчик PHP', 7, 300000, 450000, false),
        ('Devops', 8, 70000, 90000, true),
        ('Разработчик Java', 8, null, null, true),
        ('Разработчик C++', 9, null, null, true),
        ('Разработчик С#', 9, null, null, true),
        ('Разработчик танцующих машин', 10, 600000, 800000, false),
        ('Elon Musk', 11, 10000000, null, false),
        ('Уборщик ракетного топлива', 11, 100000, 150000, false), -- +health insurance
        ('Разработчик C++', 11, 400000, 600000, false),
        ('Аналитик SpaceX', 12, 200000, 260000, false), -- gotta watch out for opponents
        ('Разработчик C', 12, 300000, 700000, false);

INSERT INTO response (vacancy_id, cv_id)
SELECT
    vacancy_id,
    cv_id
FROM cv
INNER JOIN vacancy ON cv.position_name = vacancy.position_name -- yeah, could use better search
    AND (cv.desired_compensation IS NULL
        OR vacancy.compensation_to IS NULL
        OR cv.desired_compensation <= CASE  WHEN vacancy.compensation_gross
                                            THEN vacancy.compensation_to * 0.87
                                            ELSE vacancy.compensation_to
                                      END)
