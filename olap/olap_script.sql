-- Создание схемы
CREATE SCHEMA IF NOT EXISTS vgsales_olap;

-- dim_game (SCD Type 2, с release_year)
CREATE TABLE vgsales_olap.dim_game (
    game_sk SERIAL PRIMARY KEY,
    game_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    genre VARCHAR(50),
    publisher VARCHAR(100),
    release_year SMALLINT,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL
);

-- 🕹 dim_platform
CREATE TABLE vgsales_olap.dim_platform (
    platform_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- dim_region
CREATE TABLE vgsales_olap.dim_region (
    region_id CHAR(2) PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);

-- bridge_game_platform
CREATE TABLE vgsales_olap.bridge_game_platform (
    game_sk INT NOT NULL REFERENCES vgsales_olap.dim_game(game_sk),
    platform_id INT NOT NULL REFERENCES vgsales_olap.dim_platform(platform_id),
    PRIMARY KEY (game_sk, platform_id)
);

-- fact_sales (без time_id)
CREATE TABLE vgsales_olap.fact_sales (
    sales_id SERIAL PRIMARY KEY,
    game_sk INT NOT NULL REFERENCES vgsales_olap.dim_game(game_sk),
    platform_id INT NOT NULL REFERENCES vgsales_olap.dim_platform(platform_id),
    region_id CHAR(2) NOT NULL REFERENCES vgsales_olap.dim_region(region_id),
    total_sales DECIMAL(10, 2) NOT NULL
);

-- fact_critic_scores (без time_id)
CREATE TABLE vgsales_olap.fact_critic_scores (
    score_id SERIAL PRIMARY KEY,
    game_sk INT NOT NULL REFERENCES vgsales_olap.dim_game(game_sk),
    avg_score FLOAT CHECK (avg_score BETWEEN 0 AND 10)
);
