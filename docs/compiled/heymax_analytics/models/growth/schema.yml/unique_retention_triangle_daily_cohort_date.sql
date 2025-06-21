
    
    

select
    cohort_date as unique_field,
    count(*) as n_records

from "heymax"."main"."retention_triangle_daily"
where cohort_date is not null
group by cohort_date
having count(*) > 1


