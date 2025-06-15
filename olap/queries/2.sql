--Общие продажи по платформам--
SELECT p.name AS platform, SUM(fs.total_sales) AS total_sales_mln
FROM vgsales_olap.fact_sales fs
JOIN vgsales_olap.dim_platform p ON fs.platform_id = p.platform_id
GROUP BY p.name
ORDER BY total_sales_mln DESC;
