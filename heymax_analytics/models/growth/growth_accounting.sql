{{ config(materialized='table', format='parquet', order_by=['activity_date', 'country']) }}

-- 📈 Growth Accounting: Breakdown of users by behavior
-- Based on Social Capital's growth framework: https://medium.com/swlh/diligence-at-social-capital-part-1-accounting-for-user-growth-4a8a449fddfc

-- STEP 1: Unique daily activity
WITH daily_activity AS (
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('day', event_ts) AS activity_date,
        country
    FROM {{ ref('fct_events') }}
),

-- STEP 2: First seen date
first_seen AS (
    SELECT
        user_id,
        MIN(activity_date) AS first_seen_date
    FROM daily_activity
    GROUP BY user_id
),

-- STEP 3: Label user behavior
user_lifecycle AS (
    SELECT
        da.user_id,
        da.activity_date,
        da.country,
        fs.first_seen_date,
        LAG(da.activity_date) OVER (PARTITION BY da.user_id ORDER BY da.activity_date) AS prev_active_date,
        CASE
            WHEN da.activity_date = fs.first_seen_date THEN 'new'
            WHEN DATE_DIFF('day', prev_active_date, da.activity_date) = 1 THEN 'retained'
            WHEN prev_active_date IS NOT NULL THEN 'resurrected'
            ELSE 'unknown'
        END AS user_status
    FROM daily_activity da
    JOIN first_seen fs ON da.user_id = fs.user_id
),

-- STEP 4: Aggregate by date and country
daily_counts AS (
    SELECT
        activity_date,
        country,
        user_status,
        COUNT(DISTINCT user_id) AS user_count
    FROM user_lifecycle
    GROUP BY activity_date, country, user_status
),

-- STEP 5: Pivot into metrics
pivoted AS (
    SELECT
        activity_date,
        country,
        SUM(CASE WHEN user_status = 'new' THEN user_count ELSE 0 END) AS new_users,
        SUM(CASE WHEN user_status = 'retained' THEN user_count ELSE 0 END) AS retained_users,
        SUM(CASE WHEN user_status = 'resurrected' THEN user_count ELSE 0 END) AS resurrected_users
    FROM daily_counts
    GROUP BY activity_date, country
),

-- STEP 6: Churn + quick ratio
with_churn AS (
    SELECT
        p.*,
        LAG(p.retained_users) OVER (PARTITION BY country ORDER BY activity_date) AS prev_retained,
        COALESCE(LAG(p.retained_users) OVER (PARTITION BY country ORDER BY activity_date), 0) -
        COALESCE(p.retained_users, 0) AS churned_users
    FROM pivoted p
)

-- Final Output
SELECT
    activity_date,
    country,
    new_users,
    retained_users,
    resurrected_users,
    churned_users,
    ROUND((new_users + resurrected_users) * 1.0 / NULLIF(churned_users, 0), 2) AS quick_ratio
FROM with_churn
ORDER BY activity_date, country
