with deduped as (
    SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY game_id, team_id, player_id) as rn
    FROM game_details
)
SELECT * from deduped
WHERE rn = 1