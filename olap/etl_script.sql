INSERT INTO vgsales_olap.dim_platform(name)
SELECT name
FROM vgsales_oltp.platforms p
WHERE NOT EXISTS (
    SELECT 1 FROM vgsales_olap.dim_platform dp WHERE dp.name = p.name
);

INSERT INTO vgsales_olap.dim_region(region_id, name)
SELECT region_id, name
FROM vgsales_oltp.regions r
WHERE NOT EXISTS (
    SELECT 1 FROM vgsales_olap.dim_region dr WHERE dr.region_id = r.region_id
);

UPDATE vgsales_olap.dim_game d
SET end_date = CURRENT_DATE, is_current = FALSE
FROM vgsales_oltp.games g
JOIN vgsales_oltp.genres ge ON g.genre_id = ge.genre_id
JOIN vgsales_oltp.publishers p ON g.publisher_id = p.publisher_id
WHERE d.game_id = g.game_id AND d.is_current = TRUE
  AND (
      d.title IS DISTINCT FROM g.title OR
      d.genre IS DISTINCT FROM ge.name OR
      d.publisher IS DISTINCT FROM p.name OR
      d.release_year IS DISTINCT FROM g.year
  );

INSERT INTO vgsales_olap.dim_game (
    game_id, title, genre, publisher, release_year,
    start_date, end_date, is_current
)
SELECT 
    g.game_id,
    g.title,
    ge.name AS genre,
    p.name AS publisher,
    g.year,
    CURRENT_DATE,
    NULL,
    TRUE
FROM vgsales_oltp.games g
JOIN vgsales_oltp.genres ge ON g.genre_id = ge.genre_id
JOIN vgsales_oltp.publishers p ON g.publisher_id = p.publisher_id
WHERE NOT EXISTS (
    SELECT 1 FROM vgsales_olap.dim_game d
    WHERE d.game_id = g.game_id AND d.is_current = TRUE
);

INSERT INTO vgsales_olap.bridge_game_platform(game_sk, platform_id)
SELECT dg.game_sk, dp.platform_id
FROM vgsales_oltp.game_platforms gp
JOIN vgsales_olap.dim_game dg ON dg.game_id = gp.game_id AND dg.is_current = TRUE
JOIN vgsales_oltp.platforms p ON gp.platform_id = p.platform_id
JOIN vgsales_olap.dim_platform dp ON p.name = dp.name
WHERE NOT EXISTS (
    SELECT 1 FROM vgsales_olap.bridge_game_platform bgp
    WHERE bgp.game_sk = dg.game_sk AND bgp.platform_id = dp.platform_id
);

INSERT INTO vgsales_olap.fact_sales(game_sk, platform_id, region_id, total_sales)
SELECT
    dg.game_sk,
    dp.platform_id,
    s.region_id,
    SUM(s.amount)
FROM vgsales_oltp.sales s
JOIN vgsales_oltp.games g ON s.game_id = g.game_id
JOIN vgsales_oltp.platforms p ON s.platform_id = p.platform_id
JOIN vgsales_olap.dim_game dg ON g.game_id = dg.game_id AND dg.is_current = TRUE
JOIN vgsales_olap.dim_platform dp ON p.name = dp.name
GROUP BY dg.game_sk, dp.platform_id, s.region_id
HAVING NOT EXISTS (
    SELECT 1 FROM vgsales_olap.fact_sales fs
    WHERE fs.game_sk = dg.game_sk AND fs.platform_id = dp.platform_id AND fs.region_id = s.region_id
);

INSERT INTO vgsales_olap.fact_critic_scores(game_sk, avg_score)
SELECT 
    dg.game_sk,
    ROUND(AVG(c.score)::numeric, 2)
FROM vgsales_oltp.critics c
JOIN vgsales_oltp.games g ON c.game_id = g.game_id
JOIN vgsales_olap.dim_game dg ON g.game_id = dg.game_id AND dg.is_current = TRUE
GROUP BY dg.game_sk
HAVING NOT EXISTS (
    SELECT 1 FROM vgsales_olap.fact_critic_scores fcs
    WHERE fcs.game_sk = dg.game_sk
);
