-- task 3
SELECT
    vacancy.position_name AS "название вакансии",
    employer.area_id AS "город",
    employer.employer_name AS "имя работодателя"
FROM vacancy
INNER JOIN employer ON vacancy.employer_id = employer.employer_id
WHERE
    compensation_from IS NULL
    AND compensation_to IS NULL
ORDER BY vacancy.created_at DESC
LIMIT 10;

-- task 4
WITH gross AS (
    SELECT
        CASE WHEN compensation_gross IS TRUE
             THEN compensation_to
             ELSE compensation_to / 0.87
        END AS compensation_to,
        CASE WHEN compensation_gross IS TRUE
             THEN compensation_from
             ELSE compensation_from / 0.87
        END AS compensation_from
    FROM vacancy
)
SELECT
    AVG(compensation_to) AS "средняя максимальная зарплата",
    AVG(compensation_from) AS "средняя минимальная зарплата",
    AVG((compensation_to + compensation_from) / 2) AS "средняя средняя зарплата"
FROM gross;

-- task 5
WITH response_per_employer_vacancy AS (
    SELECT
        employer.employer_id AS employer_id,
        employer_name,
        COUNT(response.response_id) AS response_count
    FROM response
    RIGHT JOIN vacancy ON response.vacancy_id = vacancy.vacancy_id
    RIGHT JOIN employer ON vacancy.employer_id = employer.employer_id
    GROUP BY vacancy.vacancy_id, employer.employer_id, employer_name
), max_response_per_employer_vacancy AS (
    SELECT
        employer_id,
        employer_name,
        MAX(response_count) AS max_response_count
    FROM response_per_employer_vacancy
    GROUP BY employer_id, employer_name
)
SELECT
    employer_name AS "Компания"
FROM max_response_per_employer_vacancy
ORDER BY max_response_count DESC, employer_name ASC
LIMIT 5;

-- task 6
WITH vacancy_per_employer AS (
    SELECT DISTINCT
        employer_id,
        COUNT(*) OVER (PARTITION BY employer_id) AS vacancy_count
    FROM vacancy
)
SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vacancy_count ASC) AS "Медианное кол-во вакансий"
FROM vacancy_per_employer;

-- task 7
WITH first_response AS (
    SELECT
        area_id,
        vacancy.vacancy_id AS vacancy_id,
        MIN(response.created_at - vacancy.created_at) AS time_since_vacancy_created
    FROM vacancy
    INNER JOIN response ON vacancy.vacancy_id = response.vacancy_id
    INNER JOIN employer ON vacancy.employer_id = employer.employer_id
    GROUP BY vacancy.vacancy_id, area_id
)
SELECT
    area_id AS "Город",
    MIN(time_since_vacancy_created) AS "Минимальное время отклика",
    MAX(time_since_vacancy_created) AS "Максимальное время отклика"
FROM first_response
GROUP BY area_id;
