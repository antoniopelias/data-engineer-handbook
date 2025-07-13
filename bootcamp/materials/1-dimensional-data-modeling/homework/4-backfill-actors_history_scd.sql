WITH
    streak_started AS (
        SELECT
            actor,
            actorid,
            year,
            quality_class,
            is_active,
            LAG(quality_class, 1) OVER (
                PARTITION BY
                    actorid
                ORDER BY year
            ) <> quality_class
            OR LAG(quality_class, 1) OVER (
                PARTITION BY
                    actorid
                ORDER BY year
            ) is NULL
            OR LAG(is_active, 1) OVER (
                PARTITION BY
                    actorid
                ORDER BY year
            ) <> is_active
            OR LAG(is_active, 1) OVER (
                PARTITION BY
                    actorid
                ORDER BY year
            ) is NULL AS did_change
        FROM actors
    ),
    streak_identified AS (
        SELECT
            actor,
            actorid,
            year,
            quality_class,
            is_active,
            SUM(
                CASE
                    WHEN did_change THEN 1
                    ELSE 0
                END
            ) OVER (
                PARTITION BY
                    actorid
                ORDER BY year
            ) AS streak_id
        FROM streak_started
    )
INSERT INTO actors_history_scd
SELECT
    actor,
    actorid,
    quality_class,
    is_active,
    MIN(year) as start_date,
    MAX(year) as end_date
FROM streak_identified
GROUP BY
    actor,
    actorid,
    quality_class,
    is_active,
    streak_id;

SELECT * from actors_history_scd;