
  
  create view "heymax"."main"."retention_triangle_week__dbt_tmp" as (
    

WITH base_events AS (
    SELECT
        user_id,
        activity_week
    FROM "heymax"."main"."fct_events"
    GROUP BY user_id, activity_week
),

first_seen AS (
    SELECT
        user_id,
        MIN(activity_week) AS cohort_week
    FROM base_events
    GROUP BY user_id
),

cohort_activity AS (
    SELECT
        b.user_id,
        f.cohort_week,
        b.activity_week,
        DATE_DIFF('week', f.cohort_week, b.activity_week) AS week_index
    FROM base_events b
    JOIN first_seen f ON b.user_id = f.user_id
    WHERE DATE_DIFF('week', f.cohort_week, b.activity_week) BETWEEN 0 AND 11
),

weekly_counts AS (
    SELECT
        cohort_week,
        week_index,
        COUNT(DISTINCT user_id) AS users
    FROM cohort_activity
    GROUP BY cohort_week, week_index
),

cohort_sizes AS (
    SELECT
        cohort_week,
        MAX(CASE WHEN week_index = 0 THEN users END) AS cohort_size
    FROM weekly_counts
    GROUP BY cohort_week
)

SELECT
    wc.cohort_week,
    ROUND(SUM(CASE WHEN wc.week_index = 0 THEN users * 1.0 / cs.cohort_size END), 4) AS w0,
    ROUND(SUM(CASE WHEN wc.week_index = 1 THEN users * 1.0 / cs.cohort_size END), 4) AS w1,
    ROUND(SUM(CASE WHEN wc.week_index = 2 THEN users * 1.0 / cs.cohort_size END), 4) AS w2,
    ROUND(SUM(CASE WHEN wc.week_index = 3 THEN users * 1.0 / cs.cohort_size END), 4) AS w3,
    ROUND(SUM(CASE WHEN wc.week_index = 4 THEN users * 1.0 / cs.cohort_size END), 4) AS w4,
    ROUND(SUM(CASE WHEN wc.week_index = 5 THEN users * 1.0 / cs.cohort_size END), 4) AS w5,
    ROUND(SUM(CASE WHEN wc.week_index = 6 THEN users * 1.0 / cs.cohort_size END), 4) AS w6,
    ROUND(SUM(CASE WHEN wc.week_index = 7 THEN users * 1.0 / cs.cohort_size END), 4) AS w7,
    ROUND(SUM(CASE WHEN wc.week_index = 8 THEN users * 1.0 / cs.cohort_size END), 4) AS w8,
    ROUND(SUM(CASE WHEN wc.week_index = 9 THEN users * 1.0 / cs.cohort_size END), 4) AS w9,
    ROUND(SUM(CASE WHEN wc.week_index = 10 THEN users * 1.0 / cs.cohort_size END), 4) AS w10,
    ROUND(SUM(CASE WHEN wc.week_index = 11 THEN users * 1.0 / cs.cohort_size END), 4) AS w11
FROM weekly_counts wc
JOIN cohort_sizes cs ON wc.cohort_week = cs.cohort_week
GROUP BY wc.cohort_week
ORDER BY wc.cohort_week
  );
