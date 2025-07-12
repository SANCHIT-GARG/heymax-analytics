-- models/staging/stg_raw_events.sql
{{ config(
    materialized='table',
    format='parquet',
    order_by='event_ts'
) }}


SELECT *
FROM read_csv_auto('data/*.csv')
