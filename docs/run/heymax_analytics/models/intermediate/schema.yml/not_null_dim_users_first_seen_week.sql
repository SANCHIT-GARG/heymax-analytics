select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select first_seen_week
from "heymax"."main"."dim_users"
where first_seen_week is null



      
    ) dbt_internal_test