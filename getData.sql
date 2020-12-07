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
WITH response_per_vacancy_ordered AS (
    SELECT DISTINCT
        employer_name,
        COUNT(*) OVER (PARTITION BY vacancy.vacancy_id) AS response_count
    FROM response
    INNER JOIN vacancy ON response.vacancy_id = vacancy.vacancy_id
    INNER JOIN employer ON vacancy.employer_id = employer.employer_id
    ORDER BY response_count DESC, employer_name ASC
)
SELECT DISTINCT
    employer_name AS "Компания"
FROM response_per_vacancy_ordered
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
SELECT DISTINCT
    area_id AS "Город",
    MIN(response.created_at - vacancy.created_at) OVER (PARTITION BY area_id) AS "Минимальное время отклика",
    MAX(response.created_at - vacancy.created_at) OVER (PARTITION BY area_id) AS "Максимальное время отклика"
FROM vacancy
INNER JOIN response ON vacancy.vacancy_id = response.vacancy_id
INNER JOIN employer ON vacancy.employer_id = employer.employer_id;
