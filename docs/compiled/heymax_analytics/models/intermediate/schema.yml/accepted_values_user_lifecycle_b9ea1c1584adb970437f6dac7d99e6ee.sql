
    
    

with all_values as (

    select
        user_status as value_field,
        count(*) as n_records

    from "heymax"."main"."user_lifecycle_daily"
    group by user_status

)

select *
from all_values
where value_field not in (
    'new','retained','resurrected','churned'
)


