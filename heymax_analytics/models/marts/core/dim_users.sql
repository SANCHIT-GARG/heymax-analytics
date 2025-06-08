{{ config(materialized='table') }}

WITH first_event AS (
    SELECT
        user_id,
        MIN(event_ts) AS first_seen,
        ANY_VALUE(platform) AS platform,
        ANY_VALUE(utm_source) AS utm_source,
        ANY_VALUE(country) AS country
    FROM {{ ref('stg_events') }}
    GROUP BY user_id
)
SELECT * FROM first_event
