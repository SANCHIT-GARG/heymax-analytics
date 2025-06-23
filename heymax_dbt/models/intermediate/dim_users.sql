{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key=['user_id'],       
        partition_by={
            'field': 'activity_date',
            'data_type': 'date'
        },
        sort=['event_ts'],
        format='parquet'
    )
}}


SELECT
    user_id,
    MIN(event_ts) AS first_seen_ts,
    MIN(activity_date) as first_seen_date,
    MIN(activity_month) AS first_seen_month,
    MIN(activity_week) AS first_seen_week
FROM {{ ref('stg_events') }}
GROUP BY user_id