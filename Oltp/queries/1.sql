--Количество игр по жанрам--
SELECT ge.name AS genre, COUNT(*) AS game_count
FROM vgsales_oltp.games g
JOIN vgsales_oltp.genres ge ON g.genre_id = ge.genre_id
GROUP BY ge.name
ORDER BY game_count DESC;
