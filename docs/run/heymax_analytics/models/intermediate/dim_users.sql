
  
    
    

    create  table
      "heymax"."main"."dim_users__dbt_tmp"
  
    as (
      -- models/intermediate/dim_users.sql




SELECT
    user_id,
    MIN(event_ts) AS first_seen_ts,
    MIN(activity_date) as first_seen_date,
    MIN(activity_month) AS first_seen_month,
    MIN(activity_week) AS first_seen_week
FROM "heymax"."main"."stg_events"
GROUP BY user_id
    );
  
  