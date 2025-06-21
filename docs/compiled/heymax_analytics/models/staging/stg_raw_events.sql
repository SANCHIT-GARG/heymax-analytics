-- models/staging/stg_raw_events.sql



SELECT *
FROM read_csv_auto('data/*.csv')