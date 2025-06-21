select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select user_status
from "heymax"."main"."user_lifecycle_daily"
where user_status is null



      
    ) dbt_internal_test