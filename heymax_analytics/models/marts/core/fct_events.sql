{{ config(materialized='table') }}

SELECT
    event_ts,
    user_id,
    event_type,
    transaction_category,
    miles_amount,
    platform,
    utm_source,
    country
FROM {{ ref('stg_events') }}

