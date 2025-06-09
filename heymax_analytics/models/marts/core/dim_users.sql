-- HeyMax dbt model: dim_users.sql
-- Description: Dimension table capturing first seen date and user geography
-- Materialized as a parquet table sorted by first_seen_date

{{ config(
    materialized='table',
    format='parquet',
    sort='first_seen_date'
) }}

with first_event as (
    select
        user_id,
        min(event_ts)::date as first_seen_date,
        any_value(platform) as platform,
        any_value(utm_source) as utm_source,
        any_value(country) as country
    from {{ ref('stg_events') }}
    group by user_id
)

select * from first_event
