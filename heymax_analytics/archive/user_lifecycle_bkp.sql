-- models/intermediate/user_lifecycle.sql

{{ config(materialized='table') }}

WITH user_months AS (
    SELECT DISTINCT user_id, activity_month
    FROM {{ ref('fct_events') }}
),

-- Get all unique months
all_months AS (
    SELECT DISTINCT activity_month
    FROM {{ ref('fct_events') }}
),

-- Cross join users × months
user_month_matrix AS (
    SELECT u.user_id, m.activity_month
    FROM (SELECT DISTINCT user_id FROM {{ ref('fct_events') }}) u
    CROSS JOIN all_months m
),

-- Flag user activity by month
activity_flags AS (
    SELECT
        umm.user_id,
        umm.activity_month,
        CASE
            WHEN uma.user_id IS NOT NULL THEN 1 ELSE 0
        END AS is_active
    FROM user_month_matrix umm
    LEFT JOIN user_months uma
        ON umm.user_id = uma.user_id AND umm.activity_month = uma.activity_month
),

-- Add lagged state
lifecycle_window AS (
    SELECT *,
        LAG(is_active) OVER (PARTITION BY user_id ORDER BY activity_month) AS was_active_last_month,
        MAX(CASE WHEN is_active = 1 THEN activity_month ELSE NULL END) OVER (
            PARTITION BY user_id ORDER BY activity_month ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS last_active_before
    FROM activity_flags
),

-- Bring in first seen month
first_seen AS (
    SELECT user_id, first_seen_month
    FROM {{ ref('dim_users') }}
)

-- Assign lifecycle label
SELECT
    lw.user_id,
    lw.activity_month,
    CASE
        WHEN lw.is_active = 1 AND fs.first_seen_month = lw.activity_month THEN 'new'
        WHEN lw.is_active = 1 AND lw.was_active_last_month = 1 THEN 'retained'
        WHEN lw.is_active = 1 AND lw.was_active_last_month = 0 AND last_active_before IS NOT NULL THEN 'resurrected'
        WHEN lw.is_active = 0 AND lw.was_active_last_month = 1 THEN 'churned'
    END AS user_status
FROM lifecycle_window lw
LEFT JOIN first_seen fs ON lw.user_id = fs.user_id
WHERE user_status IS NOT NULL
