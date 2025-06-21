select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select first_seen_date
from "heymax"."main"."dim_users"
where first_seen_date is null



      
    ) dbt_internal_test