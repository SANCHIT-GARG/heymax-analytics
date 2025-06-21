

WITH base_events AS (
    SELECT
        user_id,
        activity_date
    FROM "heymax"."main"."fct_events"
    GROUP BY user_id, activity_date
),

first_seen AS (
    SELECT
        user_id,
        MIN(activity_date) AS cohort_date
    FROM base_events
    GROUP BY user_id
),

cohort_activity AS (
    SELECT
        b.user_id,
        f.cohort_date,
        b.activity_date,
        DATE_DIFF('day', f.cohort_date, b.activity_date) AS date_index
    FROM base_events b
    JOIN first_seen f ON b.user_id = f.user_id
    WHERE DATE_DIFF('day', f.cohort_date, b.activity_date) BETWEEN 0 AND 11
),

dately_counts AS (
    SELECT
        cohort_date,
        date_index,
        COUNT(DISTINCT user_id) AS users
    FROM cohort_activity
    GROUP BY cohort_date, date_index
),

cohort_sizes AS (
    SELECT
        cohort_date,
        MAX(CASE WHEN date_index = 0 THEN users END) AS cohort_size
    FROM dately_counts
    GROUP BY cohort_date
)

SELECT
    dc.cohort_date,
    ROUND(SUM(CASE WHEN dc.date_index = 0 THEN users * 1.0 / cs.cohort_size END), 4) AS d0,
    ROUND(SUM(CASE WHEN dc.date_index = 1 THEN users * 1.0 / cs.cohort_size END), 4) AS d1,
    ROUND(SUM(CASE WHEN dc.date_index = 2 THEN users * 1.0 / cs.cohort_size END), 4) AS d2,
    ROUND(SUM(CASE WHEN dc.date_index = 3 THEN users * 1.0 / cs.cohort_size END), 4) AS d3,
    ROUND(SUM(CASE WHEN dc.date_index = 4 THEN users * 1.0 / cs.cohort_size END), 4) AS d4,
    ROUND(SUM(CASE WHEN dc.date_index = 5 THEN users * 1.0 / cs.cohort_size END), 4) AS d5,
    ROUND(SUM(CASE WHEN dc.date_index = 6 THEN users * 1.0 / cs.cohort_size END), 4) AS d6,
    ROUND(SUM(CASE WHEN dc.date_index = 7 THEN users * 1.0 / cs.cohort_size END), 4) AS d7,
    ROUND(SUM(CASE WHEN dc.date_index = 8 THEN users * 1.0 / cs.cohort_size END), 4) AS d8,
    ROUND(SUM(CASE WHEN dc.date_index = 9 THEN users * 1.0 / cs.cohort_size END), 4) AS d9
FROM dately_counts dc
JOIN cohort_sizes cs ON dc.cohort_date = cs.cohort_date
GROUP BY dc.cohort_date
ORDER BY dc.cohort_date