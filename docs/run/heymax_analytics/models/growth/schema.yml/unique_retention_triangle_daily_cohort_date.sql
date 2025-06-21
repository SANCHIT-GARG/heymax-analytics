select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    cohort_date as unique_field,
    count(*) as n_records

from "heymax"."main"."retention_triangle_daily"
where cohort_date is not null
group by cohort_date
having count(*) > 1



      
    ) dbt_internal_test