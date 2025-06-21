{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key=""
        sort )
}}

WITH metrics AS (
    SELECT
        activity_date,
        COUNT_IF(user_status = 'new') AS new_users,
        COUNT_IF(user_status = 'retained') AS retained_users,
        COUNT_IF(user_status = 'resurrected') AS resurrected_users,
        COUNT_IF(user_status = 'churned') AS churned_users,
        COUNT_IF(user_status IN ('new', 'retained', 'resurrected')) AS active_users
    FROM {{ ref('user_lifecycle_daily') }}
    GROUP BY activity_date
),

-- Add lag to compute retention rate
with_lagged AS (
    SELECT
        m.*,
        LAG(active_users) OVER (ORDER BY activity_date) AS active_users_last_date
    FROM metrics m
)

SELECT
    activity_date,
    new_users,
    retained_users,
    resurrected_users,
    churned_users,
    active_users,

    -- Retention rate = retained / previous active users
    CASE
        WHEN active_users_last_date = 0 THEN NULL
        ELSE retained_users * 1.0 / active_users_last_date
    END AS retention_rate,

    -- Quick ratio = (new + resurrected) / churned
    CASE
        WHEN churned_users = 0 THEN NULL
        ELSE (new_users + resurrected_users) * 1.0 / churned_users
    END AS quick_ratio

FROM with_lagged
ORDER BY activity_date
