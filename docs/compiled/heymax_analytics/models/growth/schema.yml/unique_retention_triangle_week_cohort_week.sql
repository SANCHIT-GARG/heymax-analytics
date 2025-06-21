
    
    

select
    cohort_week as unique_field,
    count(*) as n_records

from "heymax"."main"."retention_triangle_week"
where cohort_week is not null
group by cohort_week
having count(*) > 1


