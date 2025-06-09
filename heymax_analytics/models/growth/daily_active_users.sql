{{ config(materialized='table', format='parquet', order_by=['activity_date', 'country']) }}

-- 📆 Daily Active Users (DAU)
-- Counts how many unique users were active each day per country.

SELECT
    DATE_TRUNC('day', event_ts) AS activity_date,
    country,
    COUNT(DISTINCT user_id) AS dau
FROM {{ ref('fct_events') }}
GROUP BY activity_date, country
ORDER BY activity_date, country
