{{ config(materialized='table', format='parquet', order_by=['week_start', 'country']) }}

-- 📅 Weekly Active Users (WAU)
-- Smooths daily fluctuations, measuring unique active users per week and country.

SELECT
    DATE_TRUNC('week', event_ts) AS week_start,
    country,
    COUNT(DISTINCT user_id) AS wau
FROM {{ ref('fct_events') }}
GROUP BY week_start, country
ORDER BY week_start, country
