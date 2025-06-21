select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        user_status as value_field,
        count(*) as n_records

    from "heymax"."main"."user_lifecycle_monthly"
    group by user_status

)

select *
from all_values
where value_field not in (
    'new','retained','resurrected','churned'
)



      
    ) dbt_internal_test