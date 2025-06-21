
  
    
    

    create  table
      "heymax"."main"."stg_raw_events__dbt_tmp"
  
    as (
      -- models/staging/stg_raw_events.sql



SELECT *
FROM read_csv_auto('data/*.csv')
    );
  
  