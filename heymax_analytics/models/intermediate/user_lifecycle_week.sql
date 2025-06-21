{{
    config(
        materialized='table',
        unique_key='user_id',
        partition_by={
            'field': 'activity_week',
            'data_type': 'date'
        },
        sort=['activity_week'],
        format='parquet'
    )
}}


WITH user_weeks AS (
    SELECT DISTINCT user_id, activity_week
    FROM {{ ref('fct_events') }}
),

-- Get all unique weeks
all_weeks AS (
    SELECT DISTINCT activity_week
    FROM {{ ref('fct_events') }}
),

-- Cross join users × weeks
user_week_matrix AS (
    SELECT u.user_id, m.activity_week
    FROM (SELECT DISTINCT user_id FROM {{ ref('fct_events') }}) u
    CROSS JOIN all_weeks m
),

-- Flag user activity by week
activity_flags AS (
    SELECT
        umm.user_id,
        umm.activity_week,
        CASE
            WHEN uma.user_id IS NOT NULL THEN 1 ELSE 0
        END AS is_active
    FROM user_week_matrix umm
    LEFT JOIN user_weeks uma
        ON umm.user_id = uma.user_id AND umm.activity_week = uma.activity_week
),

-- Add lagged state
lifecycle_window AS (
    SELECT *,
        LAG(is_active) OVER (PARTITION BY user_id ORDER BY activity_week) AS was_active_last_week,
        MAX(CASE WHEN is_active = 1 THEN activity_week ELSE NULL END) OVER (
            PARTITION BY user_id ORDER BY activity_week ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS last_active_before
    FROM activity_flags
),

-- Bring in first seen week
first_seen AS (
    SELECT user_id, first_seen_week
    FROM {{ ref('dim_users') }}
)

-- Assign lifecycle label
SELECT
    lw.user_id,
    lw.activity_week,
    CASE
        WHEN lw.is_active = 1 AND fs.first_seen_week = lw.activity_week THEN 'new'
        WHEN lw.is_active = 1 AND lw.was_active_last_week = 1 THEN 'retained'
        WHEN lw.is_active = 1 AND lw.was_active_last_week = 0 AND last_active_before IS NOT NULL THEN 'resurrected'
        WHEN lw.is_active = 0 AND lw.was_active_last_week = 1 THEN 'churned'
    END AS user_status
FROM lifecycle_window lw
LEFT JOIN first_seen fs ON lw.user_id = fs.user_id
WHERE user_status IS NOT NULL
