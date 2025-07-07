WITH last_year as (
    SELECT *
    FROM actors
    WHERE year = 1971
),
this_year as (
    SELECT *
    FROM actor_films
    WHERE year = 1972
)
INSERT INTO actors
SELECT 
    COALESCE(ly.actor, ty.actor) as actor,
    COALESCE(ly.actorid, ty.actorid) as actorid,
    COALESCE(ly.year + 1, ty.year) as year,
    CASE 
        WHEN ly.films IS NULL THEN ARRAY_AGG(ROW(film, votes, rating, filmid)::film)
        WHEN COUNT(ty.film) = 0 IS NULL THEN ly.films
        ELSE ly.films || ARRAY_AGG(ROW(film, votes, rating, filmid)::film)
    END
    AS films,
    CASE 
        WHEN COUNT(ty.actor) = 0 THEN ly.quality_class
        ELSE (CASE 
            WHEN AVG(ty.rating) > 8 THEN 'star'  
            WHEN AVG(ty.rating) > 7 THEN 'good'
            WHEN AVG(ty.rating) > 6 THEN 'average'
            ELSE 'bad'  
        END)::quality_class
    END AS quality_class,
    CASE 
        WHEN COUNT(ty.actor) = 0 THEN FALSE  
        ELSE TRUE
    END
    AS is_active    
FROM this_year ty FULL JOIN last_year ly
ON ty.actorid = ly.actorid
GROUP BY 
    COALESCE(ly.actor, ty.actor), 
    COALESCE(ly.actorid, ty.actorid),
    COALESCE(ly.year + 1, ty.year),
    ly.films,
    ly.quality_class;

SELECT * from actor_films LIMIT 10;

SELECT * FROM actors;