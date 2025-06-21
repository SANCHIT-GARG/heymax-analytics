
        
            delete from "heymax"."main"."user_lifecycle_week" as DBT_INCREMENTAL_TARGET
            using "user_lifecycle_week__dbt_tmp20250621105645731824"
            where (
                
                    "user_lifecycle_week__dbt_tmp20250621105645731824".user_id = DBT_INCREMENTAL_TARGET.user_id
                    and 
                
                    "user_lifecycle_week__dbt_tmp20250621105645731824".activity_week = DBT_INCREMENTAL_TARGET.activity_week
                    
                
                
            );
        
    

    insert into "heymax"."main"."user_lifecycle_week" ("user_id", "activity_week", "user_status")
    (
        select "user_id", "activity_week", "user_status"
        from "user_lifecycle_week__dbt_tmp20250621105645731824"
    )
  