-- models/intermediate/dim_users.sql

{{ config(materialized='table') }}

WITH first_event AS (
    SELECT
        user_id,
        MIN(event_ts) AS first_seen_ts
    FROM {{ ref('stg_events') }}
    GROUP BY user_id
)

SELECT
    fe.user_id,
    fe.first_seen_ts,
    DATE_TRUNC('day', fe.first_seen_ts) AS first_seen_date,
    DATE_TRUNC('month', fe.first_seen_ts) AS first_seen_month,
    DATE_TRUNC('week', fe.first_seen_ts) AS first_seen_week

FROM first_event fe
