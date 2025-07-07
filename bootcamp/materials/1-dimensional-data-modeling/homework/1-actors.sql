-- 1. DDL for actors table
CREATE TYPE film AS (
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT
);

CREATE TYPE quality_class AS ENUM ('star', 'good', 'average', 'bad');

CREATE TABLE actors (
    actor TEXT, 
    actorid TEXT,
    year INTEGER,
    films film[],
    quality_class quality_class,
    is_active BOOLEAN
)

DROP TABLE actors;