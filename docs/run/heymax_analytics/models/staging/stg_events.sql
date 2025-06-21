
  
    
    

    create  table
      "heymax"."main"."stg_events__dbt_tmp"
  
    as (
      -- models/staging/stg_events.sql



SELECT
    -- Cast and rename raw columns
    CAST(event_time AS TIMESTAMP) AS event_ts,
    DATE_TRUNC('day', CAST(event_time AS TIMESTAMP)) AS activity_date,
    DATE_TRUNC('month', CAST(event_time AS TIMESTAMP)) + INTERVAL '1 month' - INTERVAL '1 day' AS activity_month,
    DATE_TRUNC('week', CAST(event_time AS TIMESTAMP)) + INTERVAL '6 day' AS activity_week,

    -- User & event info
    CAST(user_id AS TEXT) AS user_id,
    event_type,
    transaction_category,
    CAST(miles_amount AS DOUBLE) AS miles_amount,

    -- Metadata
    platform,
    utm_source,
    country
FROM read_csv_auto('data/*.csv')
    );
  
  