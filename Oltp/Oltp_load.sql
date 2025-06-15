-- ===== 1. Загрузка справочников =====

COPY vgsales_oltp.publishers(name)
FROM 'C:/Users/aleks/Documents/coursework/oltp_data/publishers.csv'
DELIMITER ',' CSV HEADER;

COPY vgsales_oltp.genres(name)
FROM 'C:/Users/aleks/Documents/coursework/oltp_data/genres.csv'
DELIMITER ',' CSV HEADER;

COPY vgsales_oltp.platforms(name)
FROM 'C:/Users/aleks/Documents/coursework/oltp_data/platforms.csv'
DELIMITER ',' CSV HEADER;

COPY vgsales_oltp.regions(region_id, name)
FROM 'C:/Users/aleks/Documents/coursework/oltp_data/regions.csv'
DELIMITER ',' CSV HEADER;

-- ===== 2. Загрузка games =====

CREATE TEMP TABLE temp_games (
    title TEXT,
    publisher_name TEXT,
    genre_name TEXT,
    year SMALLINT
);

COPY temp_games FROM 'C:/Users/aleks/Documents/coursework/oltp_data/games.csv'
DELIMITER ',' CSV HEADER;

INSERT INTO vgsales_oltp.games (title, publisher_id, genre_id, year)
SELECT tg.title,
       p.publisher_id,
       g.genre_id,
       tg.year
FROM temp_games tg
JOIN vgsales_oltp.publishers p ON tg.publisher_name = p.name
JOIN vgsales_oltp.genres g ON tg.genre_name = g.name
WHERE NOT EXISTS (
    SELECT 1 FROM vgsales_oltp.games ex
    WHERE ex.title = tg.title AND ex.year = tg.year
);

-- ===== 3. Загрузка game_platforms =====

CREATE TEMP TABLE temp_game_platforms (
    title TEXT,
    platform_name TEXT
);

COPY temp_game_platforms FROM 'C:/Users/aleks/Documents/coursework/oltp_data/game_platforms.csv'
DELIMITER ',' CSV HEADER;

INSERT INTO vgsales_oltp.game_platforms (game_id, platform_id)
SELECT g.game_id, p.platform_id
FROM temp_game_platforms tgp
JOIN vgsales_oltp.games g ON tgp.title = g.title
JOIN vgsales_oltp.platforms p ON tgp.platform_name = p.name
WHERE NOT EXISTS (
    SELECT 1 FROM vgsales_oltp.game_platforms gp
    WHERE gp.game_id = g.game_id AND gp.platform_id = p.platform_id
);

-- ===== 4. Загрузка sales =====

CREATE TEMP TABLE temp_sales (
    title TEXT,
    platform_name TEXT,
    region_code CHAR(2),
    amount DECIMAL(10,2)
);

COPY temp_sales FROM 'C:/Users/aleks/Documents/coursework/oltp_data/sales.csv'
DELIMITER ',' CSV HEADER;

INSERT INTO vgsales_oltp.sales (game_id, region_id, platform_id, amount)
SELECT g.game_id, ts.region_code, p.platform_id, ts.amount
FROM temp_sales ts
JOIN vgsales_oltp.games g ON ts.title = g.title
JOIN vgsales_oltp.platforms p ON ts.platform_name = p.name
WHERE NOT EXISTS (
    SELECT 1 FROM vgsales_oltp.sales s
    WHERE s.game_id = g.game_id AND s.region_id = ts.region_code AND s.platform_id = p.platform_id
);

-- ===== 5. Загрузка critics =====

CREATE TEMP TABLE temp_critics (
    game_title TEXT,
    score FLOAT,
    source TEXT
);

COPY temp_critics FROM 'C:/Users/aleks/Documents/coursework/oltp_data/critics.csv'
DELIMITER ',' CSV HEADER;

INSERT INTO vgsales_oltp.critics (game_id, score, source)
SELECT g.game_id, tc.score, tc.source
FROM temp_critics tc
JOIN vgsales_oltp.games g ON tc.game_title = g.title
WHERE NOT EXISTS (
    SELECT 1 FROM vgsales_oltp.critics c
    WHERE c.game_id = g.game_id AND c.source = tc.source
);
