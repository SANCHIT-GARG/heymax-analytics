
    
    

select
    activity_week as unique_field,
    count(*) as n_records

from "heymax"."main"."growth_metrics_week"
where activity_week is not null
group by activity_week
having count(*) > 1


