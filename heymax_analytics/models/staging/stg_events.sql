{{ config(materialized='table') }}

SELECT
    CAST(event_time AS TIMESTAMP) AS event_ts,
    CAST(user_id AS TEXT) AS user_id,
    event_type,
    transaction_category,
    CAST(miles_amount AS DOUBLE) AS miles_amount,
    platform,
    utm_source,
    country
FROM read_csv_auto('data/event_stream.csv')
