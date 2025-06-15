--Суммарные продажи по регионам--
SELECT r.name AS region, ROUND(SUM(s.amount), 2) AS total_sales_mln
FROM vgsales_oltp.sales s
JOIN vgsales_oltp.regions r ON s.region_id = r.region_id
GROUP BY r.name
ORDER BY total_sales_mln DESC;