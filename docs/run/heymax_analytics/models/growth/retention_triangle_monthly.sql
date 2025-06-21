
  
  create view "heymax"."main"."retention_triangle_monthly__dbt_tmp" as (
    

WITH base_events AS (
    SELECT
        user_id,
        activity_month
    FROM "heymax"."main"."fct_events"
    GROUP BY user_id, activity_month
),

first_seen AS (
    SELECT
        user_id,
        MIN(activity_month) AS cohort_month
    FROM base_events
    GROUP BY user_id
),

cohort_activity AS (
    SELECT
        b.user_id,
        f.cohort_month,
        b.activity_month,
        DATE_DIFF('month', f.cohort_month, b.activity_month) AS month_index
    FROM base_events b
    JOIN first_seen f ON b.user_id = f.user_id
),

monthly_counts AS (
    SELECT
        cohort_month,
        month_index,
        COUNT(DISTINCT user_id) AS users
    FROM cohort_activity
    GROUP BY cohort_month, month_index
),

cohort_sizes AS (
    SELECT
        cohort_month,
        MAX(CASE WHEN month_index = 0 THEN users END) AS cohort_size
    FROM monthly_counts
    GROUP BY cohort_month
)

SELECT
    mc.cohort_month,
    ROUND(SUM(CASE WHEN mc.month_index = 0 THEN users * 1.0 / cs.cohort_size END), 4) AS m0,
    ROUND(SUM(CASE WHEN mc.month_index = 1 THEN users * 1.0 / cs.cohort_size END), 4) AS m1,
    ROUND(SUM(CASE WHEN mc.month_index = 2 THEN users * 1.0 / cs.cohort_size END), 4) AS m2,
    ROUND(SUM(CASE WHEN mc.month_index = 3 THEN users * 1.0 / cs.cohort_size END), 4) AS m3,
    ROUND(SUM(CASE WHEN mc.month_index = 4 THEN users * 1.0 / cs.cohort_size END), 4) AS m4,
    ROUND(SUM(CASE WHEN mc.month_index = 5 THEN users * 1.0 / cs.cohort_size END), 4) AS m5
FROM monthly_counts mc
JOIN cohort_sizes cs ON mc.cohort_month = cs.cohort_month
GROUP BY mc.cohort_month
ORDER BY mc.cohort_month
  );
