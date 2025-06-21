select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    cohort_week as unique_field,
    count(*) as n_records

from "heymax"."main"."retention_triangle_week"
where cohort_week is not null
group by cohort_week
having count(*) > 1



      
    ) dbt_internal_test