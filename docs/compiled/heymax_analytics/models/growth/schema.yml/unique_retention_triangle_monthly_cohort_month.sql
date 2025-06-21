
    
    

select
    cohort_month as unique_field,
    count(*) as n_records

from "heymax"."main"."retention_triangle_monthly"
where cohort_month is not null
group by cohort_month
having count(*) > 1


