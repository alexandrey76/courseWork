--Игры, выпущенные Nintendo на платформе Wii--
SELECT g.title, g.year
FROM vgsales_oltp.games g
JOIN vgsales_oltp.publishers p ON g.publisher_id = p.publisher_id
JOIN vgsales_oltp.game_platforms gp ON g.game_id = gp.game_id
JOIN vgsales_oltp.platforms pl ON gp.platform_id = pl.platform_id
WHERE p.name = 'Nintendo' AND pl.name = 'Wii';
