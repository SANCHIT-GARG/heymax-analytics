select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    activity_week as unique_field,
    count(*) as n_records

from "heymax"."main"."growth_metrics_week"
where activity_week is not null
group by activity_week
having count(*) > 1



      
    ) dbt_internal_test