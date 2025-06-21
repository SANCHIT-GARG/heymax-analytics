select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select cohort_date
from "heymax"."main"."retention_triangle_daily"
where cohort_date is null



      
    ) dbt_internal_test