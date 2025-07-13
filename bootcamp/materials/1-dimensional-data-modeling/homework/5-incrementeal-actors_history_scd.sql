# if same class (ends this year) -> replace using this new year
CREATE TYPE scd_type AS (
                    quality_class quality_class,
                    is_active boolean,
                    start_date INTEGER,
                    end_date INTEGER
                        );

WITH
    vars (current_year) AS (
        VALUES (1981)
    ),
    historic AS (
        SELECT
            actor,
            actorid,
            quality_class,
            is_active,
            start_date,
            end_date
        FROM actors_history_scd, vars
        WHERE
            end_date < vars.current_year - 1
    ),
    this_year_data AS (
        SELECT *
        FROM actors
        WHERE
            year = (
                SELECT current_year
                FROM vars
            )
    ),
    different_class AS (
        SELECT a.actor, a.actorid, UNNEST(
                ARRAY[
                    ROW (
                        scd.quality_class, scd.is_active, scd.start_date, scd.end_date
                    )::scd_type, ROW (
                        a.quality_class, a.is_active, (
                            SELECT current_year
                            FROM vars
                        ), (
                            SELECT current_year
                            FROM vars
                        )
                    )::scd_type
                ]
            ) as records
        FROM
            actors_history_scd scd
            JOIN this_year_data a ON a.actorid = scd.actorid
        WHERE
            scd.end_date = (
                SELECT current_year
                FROM vars
            ) - 1
            AND (
                scd.quality_class <> a.quality_class
                OR scd.is_active <> a.is_active
            )
    ),
    unnest_diff_class as (
        SELECT actor, actorid, (records::scd_type).quality_class, (records::scd_type).is_active, (records::scd_type).start_date, (records::scd_type).end_date
        FROM different_class
    ),
    same_class AS (
        SELECT scd.actor, scd.actorid, scd.quality_class, scd.is_active, scd.start_date, (
                SELECT current_year
                FROM vars
            ) as end_date
        FROM
            actors_history_scd scd
            JOIN this_year_data ty ON ty.actorid = scd.actorid
            WHERE scd.end_date = (
                SELECT current_year
                FROM vars
            ) - 1
            AND scd.quality_class = ty.quality_class and scd.is_active = ty.is_active
    ), new_actor as (
        SELECT
            ty.actor,
            ty.actorid,
            ty.quality_class,
            ty.is_active,
            (
                SELECT current_year
                FROM vars
            ) as start_date,
            (
                SELECT current_year
                FROM vars
            ) as end_date
        FROM
            this_year_data ty
            LEFT JOIN actors_history_scd scd ON ty.actorid = scd.actorid
        WHERE
            scd.actorid is NULL
    )
SELECT *
FROM (
        SELECT *
        FROM historic
        UNION ALL
        SELECT *
        FROM unnest_diff_class
        UNION ALL
        SELECT *
        FROM new_actor
        UNION ALL
        SELECT *
        FROM same_class
    ) a;

SELECT * FROM actors;

SELECT * FROM actors_history_scd;

-- CREATE TABLE actors_history_scd (
--     actor TEXT,
--     actorid TEXT,
--     quality_class quality_class,
--     is_active BOOLEAN,
--     start_date INTEGER,
--     end_date INTEGER
-- );

SELECT * FROM actors;