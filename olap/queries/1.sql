-- Средняя оценка по жанрам --
SELECT genre, ROUND(AVG(avg_score)::numeric, 2) AS avg_rating
FROM vgsales_olap.fact_critic_scores f
JOIN vgsales_olap.dim_game g ON f.game_sk = g.game_sk
GROUP BY genre
ORDER BY avg_rating DESC;
