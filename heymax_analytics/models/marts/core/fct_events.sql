-- HeyMax dbt model: fct_events.sql
-- Description: Core fact table of user events
-- Materialized as a parquet table sorted by event_ts for performance

{{ config(
    materialized='table',
    format='parquet',
    sort='event_ts'
) }}

select
    event_ts,
    user_id,
    event_type,
    transaction_category,
    miles_amount,
    platform,
    utm_source,
    country
from {{ ref('stg_events') }}
