INSERT into user_devices_cumulated 
with yesterday as (
    SELECT * from user_devices_cumulated
), 
today as (
    SELECT 
        user_id, 
        DATE(event_time) as dt, 
        browser_type
    FROM events e
    JOIN devices d 
        ON e.device_id = d.device_id 
    WHERE DATE(event_time) = date('2023-01-03') and user_id is not null
    GROUP BY user_id, DATE(event_time), browser_type
)
SELECT 
    COALESCE(t.user_id, y.user_id), 
    COALESCE(t.browser_type, y.browser_type), 
    CASE 
        WHEN t.user_id is NULL THEN y.active_days
        WHEN y.active_days is NULL THEN t.dt || ARRAY[]::DATE[]
        ELSE t.dt || y.active_days
    END as active_days
from yesterday y 
FULL JOIN today t 
on y.user_id = t.user_id and y.browser_type = t.browser_type