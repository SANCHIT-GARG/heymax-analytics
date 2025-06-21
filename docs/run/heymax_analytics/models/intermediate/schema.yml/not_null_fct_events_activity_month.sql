select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select activity_month
from "heymax"."main"."fct_events"
where activity_month is null



      
    ) dbt_internal_test