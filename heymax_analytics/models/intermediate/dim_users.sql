-- models/intermediate/dim_users.sql

{{ config(materialized='table') }}


SELECT
    user_id,
    MIN(event_ts) AS first_seen_ts,
    MIN(activity_date) as first_seen_date,
    MIN(activity_month) AS first_seen_month,
    MIN(activity_week) AS first_seen_week
FROM {{ ref('stg_events') }}
GROUP BY user_id