select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select cohort_week
from "heymax"."main"."retention_triangle_week"
where cohort_week is null



      
    ) dbt_internal_test