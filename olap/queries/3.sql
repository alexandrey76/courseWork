--ТОП-10 игр по оценке критиков--
SELECT g.title, g.genre, g.publisher, f.avg_score
FROM vgsales_olap.fact_critic_scores f
JOIN vgsales_olap.dim_game g ON f.game_sk = g.game_sk
ORDER BY f.avg_score DESC
LIMIT 10;
