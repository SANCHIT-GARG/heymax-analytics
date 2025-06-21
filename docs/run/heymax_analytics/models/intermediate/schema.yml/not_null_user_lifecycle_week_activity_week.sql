select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select activity_week
from "heymax"."main"."user_lifecycle_week"
where activity_week is null



      
    ) dbt_internal_test