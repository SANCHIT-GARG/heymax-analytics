-- models/intermediate/fct_events.sql

{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key=['user_id', 'event_ts'],       
        partition_by={
            'field': 'activity_date',
            'data_type': 'date'
        },
        sort=['event_ts'],
        format='parquet'
    )
}}

-- TODO: Add event filters (e.g., only miles_*), derived metrics later

SELECT
    event_ts,
    activity_date,
    activity_month,
    activity_week,
    user_id,
    event_type,
    transaction_category,
    miles_amount,
    platform,
    utm_source,
    country
FROM {{ ref('stg_events') }}
