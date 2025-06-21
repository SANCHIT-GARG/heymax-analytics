
        
            delete from "heymax"."main"."user_lifecycle_monthly" as DBT_INCREMENTAL_TARGET
            using "user_lifecycle_monthly__dbt_tmp20250621110205972728"
            where (
                
                    "user_lifecycle_monthly__dbt_tmp20250621110205972728".user_id = DBT_INCREMENTAL_TARGET.user_id
                    and 
                
                    "user_lifecycle_monthly__dbt_tmp20250621110205972728".activity_month = DBT_INCREMENTAL_TARGET.activity_month
                    
                
                
            );
        
    

    insert into "heymax"."main"."user_lifecycle_monthly" ("user_id", "activity_month", "user_status")
    (
        select "user_id", "activity_month", "user_status"
        from "user_lifecycle_monthly__dbt_tmp20250621110205972728"
    )
  