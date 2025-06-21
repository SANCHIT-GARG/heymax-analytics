
        
            delete from "heymax"."main"."user_lifecycle_daily" as DBT_INCREMENTAL_TARGET
            using "user_lifecycle_daily__dbt_tmp20250621110205855750"
            where (
                
                    "user_lifecycle_daily__dbt_tmp20250621110205855750".user_id = DBT_INCREMENTAL_TARGET.user_id
                    and 
                
                    "user_lifecycle_daily__dbt_tmp20250621110205855750".activity_date = DBT_INCREMENTAL_TARGET.activity_date
                    
                
                
            );
        
    

    insert into "heymax"."main"."user_lifecycle_daily" ("user_id", "activity_date", "user_status")
    (
        select "user_id", "activity_date", "user_status"
        from "user_lifecycle_daily__dbt_tmp20250621110205855750"
    )
  