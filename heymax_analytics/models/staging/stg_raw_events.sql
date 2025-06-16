-- models/staging/stg_raw_events.sql
{{ config(materialized='table') }}

SELECT *
FROM read_csv_auto('data/event_stream.csv')
