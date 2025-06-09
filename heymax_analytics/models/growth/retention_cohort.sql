{{ config(materialized='table', format='parquet', order_by=['cohort_date', 'days_since_signup', 'country']) }}

-- 📊 Retention Cohort Model
-- Tracks how many users return after their signup date (cohort), broken down by:
--   - cohort_date (first seen date)
--   - days_since_signup (0 = day of signup, 1 = next day, etc.)
--   - country
-- This helps visualize user retention behavior over time.

-- STEP 1: Normalize user activity to day level
WITH user_activity AS (
    SELECT
        user_id,
        DATE_TRUNC('day', event_ts) AS activity_date,
        country
    FROM {{ ref('fct_events') }}
),

-- STEP 2: Identify user’s first seen date (cohort)
first_seen AS (
    SELECT
        user_id,
        MIN(activity_date) AS cohort_date
    FROM user_activity
    GROUP BY user_id
),

-- STEP 3: Join activity with cohort and compute days since signup
cohort_activity AS (
    SELECT
        ua.user_id,
        fs.cohort_date,
        ua.activity_date,
        ua.country,
        DATE_DIFF('day', fs.cohort_date, ua.activity_date) AS days_since_signup
    FROM user_activity ua
    JOIN first_seen fs ON ua.user_id = fs.user_id
    WHERE ua.activity_date >= fs.cohort_date
),

-- STEP 4: Aggregate retention by cohort date, day offset, and country
retention AS (
    SELECT
        cohort_date,
        days_since_signup,
        country,
        COUNT(DISTINCT user_id) AS retained_users
    FROM cohort_activity
    GROUP BY cohort_date, days_since_signup, country
)

-- Final output
SELECT *
FROM retention
ORDER BY cohort_date, days_since_signup, country
-- This final output provides a clear view of how many users return on each day after their initial signup,
-- segmented by their cohort date and country. It allows for easy analysis of user retention trends over time.