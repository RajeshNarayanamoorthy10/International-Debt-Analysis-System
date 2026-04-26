-- =====================================================
-- Project      : International Debt Analysis System
-- Phase        : SQL Analytical Queries
-- Author       : Rajesh
-- Description  : 30 SQL queries for debt analysis
-- =====================================================
-- -----Basic Queries------------
-- 1.  Retrieve all distinct country names
SELECT distinct long_name
FROM countries;

-- 2.  Count total number of countries
SELECT COUNT(distinct country_code) as total_number_of_countries
FROM countries;

-- 3.  Find total number of indicators
SELECT COUNT(DISTINCT series_code) total_number_of_indicators
FROM indicators;

-- 4.  Display first 10 records of debt_data
SELECT id,country_code,series_code,year,debt_value
FROM debt_data
LIMIT 10;

-- 5.  Calculate total global debt
SELECT SUM(debt_value) as total_global_debt
FROM debt_data;

-- 6.  List all unique indicator names
SELECT distinct indicator_name
FROM indicators;

-- 7.  Find number of records for each country
SELECT long_name, COUNT(series_code) as total_records
FROM debt_data dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY long_name
ORDER BY total_records DESC;

-- 8.  Display all records where debt_value > 1 billion
SELECT id,country_code,series_code,year,debt_value
FROM debt_data
WHERE debt_value>1000000000
ORDER BY debt_value DESC;

-- 9.  Find minimum, maximum and average debt values
SELECT min(debt_value) as minimum_debt,max(debt_value) as maximum_debt,ROUND(Avg(debt_value),2) as average_debt
FROM debt_data;

-- 10. Count total number of records in debt_data
SELECT COUNT(*) total_records
FROM debt_data;

-- -----Intermediate Queries------------
-- 1.  Find total debt for each country
SELECT long_name as country,ROUND(sum(debt_value),2) as total_debt
FROM debt_data as dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY long_name
ORDER BY country;

SET SESSION wait_timeout = 600;
SET SESSION interactive_timeout = 600;
-- 2.  Display top 10 countries with highest total debt
SELECT long_name as country,ROUND(sum(debt_value),2) as total_debt
FROM debt_data as dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY long_name
ORDER BY total_debt DESC
LIMIT 10;

-- 3.  Find average debt per country
SELECT long_name as country,ROUND(AVG(debt_value),2) as total_debt
FROM debt_data as dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY long_name
ORDER BY long_name;

-- 4.  Calculate total debt for each indicator
SELECT indicator_name,dd.series_code,ROUND(SUM(debt_value),2) as total_debt
FROM debt_data dd
JOIN indicators i
ON dd.series_code = i.series_code
GROUP BY indicator_name;

-- 5.  Identify indicator contributing highest total debt
WITH rnk_CTE as (SELECT indicator_name,dd.series_code,ROUND(SUM(debt_value),2) as total_debt,
dense_rank() OVER(ORDER BY SUM(debt_value) DESC) as rnk
FROM debt_data dd
JOIN indicators i
ON dd.series_code = i.series_code
GROUP BY indicator_name,dd.series_code)
SELECT *
FROM rnk_CTE
WHERE rnk = 1;

CREATE INDEX idx_country_code ON debt_data(country_code);
CREATE INDEX idx_series_code ON debt_data(series_code);

-- 6.  Find country with lowest total debt
SELECT long_name,ROUND(SUM(debt_value),2) total_debt
FROM debt_data dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY long_name
ORDER BY total_debt 
LIMIT 1;

-- 7.  Calculate total debt for each country and indicator combination
SELECT long_name,indicator_name,ROUND(SUM(debt_value),2) as total_debt
FROM debt_data dd
JOIN countries c ON dd.country_code = c.country_code
JOIN indicators i on dd.series_code = i.series_code
GROUP BY long_name,indicator_name;

-- 8.  Count how many indicators each country has
SELECT c.long_name, COUNT(distinct dd.series_code) indicator_count
FROM debt_data dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY c.long_name
ORDER BY indicator_count DESC;
-- 9.  Display countries whose total debt is above global average
SELECT c.long_name, ROUND(SUM(debt_value),2) total_debt
FROM debt_data dd
JOIN countries c ON dd.country_code = c.country_code
GROUP BY c.long_name
HAVING sum(debt_value) > (
SELECT avg(debt_value)
FROM debt_data);

-- 10. Rank countries based on total debt (highest to lowest)
SELECT c.long_name,ROUND(SUM(debt_value),2) total_debt,
DENSE_RANK() OVER(ORDER BY SUM(debt_value) DESC) as rnk
FROM debt_data dd
JOIN countries c ON dd.country_code = c.country_code
GROUP BY c.long_name;


-- -----Advanced Queries------------
-- 1.  Find top 5 indicators contributing most to global debt
WITH rnk_CTE AS (SELECT indicator_name,
dense_rank() OVER(ORDER BY SUM(debt_value) DESC) rnk
FROM debt_data dd
JOIN indicators i 
ON dd.series_code = i.series_code
GROUP BY indicator_name)
SELECT indicator_name
FROM rnk_CTE
WHERE rnk <=5;

-- 2.  Calculate percentage contribution of each country to total global debt
SELECT c.long_name, ROUND(SUM(debt_value)/(SELECT sum(debt_value) FROM debt_data) *100,2) as percentage_contribution
FROM debt_data dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY c.long_name
ORDER BY percentage_contribution DESC;

-- 3.  Identify top 3 countries for each indicator based on debt
WITH rnk_cte as (SELECT indicator_name, c.long_name,ROUND(SUM(debt_value),2),
dense_rank() OVER(PARTITION BY indicator_name ORDER BY SUM(debt_value) DESC) as rnk
FROM debt_data dd
JOIN countries c ON dd.country_code = c.country_code
JOIN indicators i on dd.series_code = i.series_code
GROUP BY indicator_name,c.long_name)
SELECT *
FROM rnk_cte
WHERE rnk <=3;

-- 4.  Find difference between maximum and minimum debt for each country
SELECT c.long_name, MAX(debt_value) - MIN(debt_value) as MAXMIN_debt_diff	
FROM debt_data dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY c.long_name;


-- 5.  Create a VIEW for top 10 countries with highest debt
DROP  VIEW top_10_countries;

CREATE view top_10_countries AS 
SELECT * FROM (
SELECT c.long_name, ROUND(SUM(debt_value),2) as total_debt
FROM debt_data dd
JOIN countries c
ON c.country_code = dd.country_code
GROUP BY c.long_name
ORDER BY total_debt DESC
LIMIT 10) AS top10;

SELECT * FROM top_10_countries;

-- 6.  Categorize countries into High, Medium, Low debt using CASE
SELECT c.long_name,
       ROUND(SUM(debt_value),2) as total_debt,
       CASE 
           WHEN SUM(debt_value) > 100000000000000 THEN 'High Debt'
           WHEN SUM(debt_value) > 10000000000000 THEN 'Medium Debt'
           ELSE 'Low Debt'
       END as debt_category
FROM debt_data dd
JOIN countries c ON dd.country_code = c.country_code
GROUP BY c.long_name
ORDER BY total_debt DESC;

-- 7.  Use window functions to calculate cumulative debt per country
SELECT c.long_name,
       dd.year,
       ROUND(SUM(debt_value),2) as yearly_debt,
       ROUND(SUM(SUM(debt_value)) OVER(PARTITION BY c.long_name ORDER BY dd.year),2) as cumulative_debt
FROM debt_data dd
JOIN countries c ON dd.country_code = c.country_code
GROUP BY c.long_name, dd.year
ORDER BY c.long_name, dd.year;

-- 8.  Find indicators where average debt is higher than overall average
SELECT indicator_name, avg(debt_value) avg_debt_value
FROM debt_data dd
JOIN indicators i 
ON dd.series_code = i.series_code
GROUP BY indicator_name
HAVING avg(debt_value) > (select avg(debt_value) FROM debt_data);

-- 9.  Identify countries contributing more than 5% of global debt
SELECT c.long_name, ROUND(SUM(debt_value)/(SELECT sum(debt_value) FROM debt_data) *100,2) as percentage_contribution
FROM debt_data dd
JOIN countries c
ON dd.country_code = c.country_code
GROUP BY c.long_name
HAVING ROUND(SUM(debt_value)/(SELECT sum(debt_value) FROM debt_data) *100,2) >= 5;

-- 10. Find most dominant indicator for each country
WITH CTE AS (SELECT c.long_name,i.indicator_name,
DENSE_RANK() OVER(partition by c.long_name ORDER BY SUM(debt_value) DESC) rnk
FROM debt_data dd
JOIN countries c ON dd.country_code = c.country_code
JOIN indicators i on dd.series_code = i.series_code
GROUP BY c.long_name,i.indicator_name)
SELECT *
FROM CTE 
WHERE rnk =1;
