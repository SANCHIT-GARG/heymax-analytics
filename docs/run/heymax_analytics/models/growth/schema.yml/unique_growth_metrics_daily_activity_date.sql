select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    activity_date as unique_field,
    count(*) as n_records

from "heymax"."main"."growth_metrics_daily"
where activity_date is not null
group by activity_date
having count(*) > 1



      
    ) dbt_internal_test