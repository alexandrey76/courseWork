-- Создание схемы
CREATE SCHEMA IF NOT EXISTS vgsales_oltp;

-- Таблица издателей
CREATE TABLE vgsales_oltp.publishers (
    publisher_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Таблица жанров
CREATE TABLE vgsales_oltp.genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Таблица платформ
CREATE TABLE vgsales_oltp.platforms (
    platform_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Таблица регионов
CREATE TABLE vgsales_oltp.regions (
    region_id CHAR(2) PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);

-- Таблица игр (основная сущность)
CREATE TABLE vgsales_oltp.games (
    game_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    publisher_id INT NOT NULL REFERENCES vgsales_oltp.publishers(publisher_id),
    genre_id INT NOT NULL REFERENCES vgsales_oltp.genres(genre_id),
    year SMALLINT CHECK (year BETWEEN 1980 AND 2100)
);

-- Связующая таблица Игры-Платформы (многие-ко-многим)
CREATE TABLE vgsales_oltp.game_platforms (
    game_id INT NOT NULL REFERENCES vgsales_oltp.games(game_id),
    platform_id INT NOT NULL REFERENCES vgsales_oltp.platforms(platform_id),
    PRIMARY KEY (game_id, platform_id)
);

-- Таблица продаж
CREATE TABLE vgsales_oltp.sales (
    sale_id SERIAL PRIMARY KEY,
    game_id INT NOT NULL REFERENCES vgsales_oltp.games(game_id),
    region_id CHAR(2) NOT NULL REFERENCES vgsales_oltp.regions(region_id),
    platform_id INT NOT NULL REFERENCES vgsales_oltp.platforms(platform_id),
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0)
);

-- Таблица оценок критиков
CREATE TABLE vgsales_oltp.critics (
    critic_id SERIAL PRIMARY KEY,
    game_id INT NOT NULL REFERENCES vgsales_oltp.games(game_id),
    score FLOAT NOT NULL CHECK (score BETWEEN 0 AND 10),
    source VARCHAR(100) NOT NULL
);