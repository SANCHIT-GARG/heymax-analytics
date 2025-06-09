{{ config(materialized='table', format='parquet', order_by=['month_start', 'country']) }}

-- 📆 Monthly Active Users (MAU)
-- High-level engagement snapshot: users active per month per country.

SELECT
    DATE_TRUNC('month', event_ts) AS month_start,
    country,
    COUNT(DISTINCT user_id) AS mau
FROM {{ ref('fct_events') }}
GROUP BY month_start, country
ORDER BY month_start, country
