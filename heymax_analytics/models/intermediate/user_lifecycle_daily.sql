{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key='user_id',
        partition_by={
            'field': 'activity_date',
            'data_type': 'date'
        },
        sort=['activity_date']
        format='parquet'
    )
}}


WITH user_dates AS (
    SELECT DISTINCT user_id, activity_date
    FROM {{ ref('fct_events') }}
),

-- Get all unique dates
all_dates AS (
    SELECT DISTINCT activity_date
    FROM {{ ref('fct_events') }}
),

-- Cross join users × dates
user_date_matrix AS (
    SELECT u.user_id, m.activity_date
    FROM (SELECT DISTINCT user_id FROM {{ ref('fct_events') }}) u
    CROSS JOIN all_dates m
),

-- Flag user activity by date
activity_flags AS (
    SELECT
        umm.user_id,
        umm.activity_date,
        CASE
            WHEN uma.user_id IS NOT NULL THEN 1 ELSE 0
        END AS is_active
    FROM user_date_matrix umm
    LEFT JOIN user_dates uma
        ON umm.user_id = uma.user_id AND umm.activity_date = uma.activity_date
),

-- Add lagged state
lifecycle_window AS (
    SELECT *,
        LAG(is_active) OVER (PARTITION BY user_id ORDER BY activity_date) AS was_active_last_date,
        MAX(CASE WHEN is_active = 1 THEN activity_date ELSE NULL END) OVER (
            PARTITION BY user_id ORDER BY activity_date ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS last_active_before
    FROM activity_flags
),

-- Bring in first seen date
first_seen AS (
    SELECT user_id, first_seen_date
    FROM {{ ref('dim_users') }}
)

-- Assign lifecycle label
SELECT
    lw.user_id,
    lw.activity_date,
    CASE
        WHEN lw.is_active = 1 AND fs.first_seen_date = lw.activity_date THEN 'new'
        WHEN lw.is_active = 1 AND lw.was_active_last_date = 1 THEN 'retained'
        WHEN lw.is_active = 1 AND lw.was_active_last_date = 0 AND last_active_before IS NOT NULL THEN 'resurrected'
        WHEN lw.is_active = 0 AND lw.was_active_last_date = 1 THEN 'churned'
    END AS user_status
FROM lifecycle_window lw
LEFT JOIN first_seen fs ON lw.user_id = fs.user_id
WHERE user_status IS NOT NULL
