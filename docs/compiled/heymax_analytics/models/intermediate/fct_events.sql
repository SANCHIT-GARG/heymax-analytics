-- models/intermediate/fct_events.sql



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
FROM "heymax"."main"."stg_events"