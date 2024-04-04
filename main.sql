-- COPY raw_walmart
-- FROM '/path/Walmart.csv'
-- DELIMITER ','
-- CSV HEADER;

-- update raw_walmart
-- set "Date" = TO_CHAR(TO_DATE("Date", 'DD-MM-YYYY'), 'YYYY-MM-DD')

--Sales (4 Weeks Rolling Average, Weekly Groth Rate)
select 
	"Store",
	"Date", 
 	"Weekly_Sales",
	ROUND( cast(AVG("Weekly_Sales") OVER (Partition by "Store" ORDER BY "Date" ROWS BETWEEN 3 PRECEDING AND 0 FOLLOWING) as numeric),2) AS "4_Weeks_Rolling_Average",
	ROUND( cast(("Weekly_Sales" - LAG("Weekly_Sales", 1) OVER (Partition by "Store" ORDER BY "Date")) / LAG("Weekly_Sales", 1) OVER (ORDER BY "Date") as numeric),2) AS "Weekly_Growth_Rate"
from raw_walmart
order by "Store","Date" asc

--Store Sales Distribution
DROP TABLE IF EXISTS temp_store_sales;
create temp table temp_store_sales as 
select 
	"Store",
	ROUND(cast(sum("Weekly_Sales")as numeric),2) as "Store_Sales"
from raw_walmart
group by "Store"
order by "Store";

SELECT
    "Store",
    "Store_Sales",
	round(cast( "Store_Sales" / (SELECT SUM("Store_Sales") FROM temp_store_sales)as numeric),4) AS "Sales_Distribution"
FROM
    temp_store_sales

--Correlation Analysis
select 
	round(cast ( CORR("Weekly_Sales", "Temperature") as numeric),4) as "Sales_Vs_Temp",
	round(cast ( CORR("Weekly_Sales", "Fuel_Price") as numeric),4) as "Sales_Vs_Fuel",
	round(cast ( CORR("Weekly_Sales", "CPI") as numeric),4) as "Sales_Vs_CPI", 
	round(cast ( CORR("Weekly_Sales", "Unemployment") as numeric),4) as "Sales_Vs_Unemployment"
from raw_walmart

--Holiday Sales
DROP TABLE IF EXISTS temp_sales_holiday;
create temp table temp_sales_holiday as 
SELECT
	"Store",
    "Holiday_Flag",
    round(cast( AVG("Weekly_Sales") as numeric),2) AS "Average_Weekly_Sales"
FROM
    raw_walmart
GROUP BY
	"Store", "Holiday_Flag"
order by
	"Store";

select
	"Store",
    round(AVG(CASE WHEN "Holiday_Flag" = 1 THEN "Average_Weekly_Sales" END),2) AS "Average_Weekly_Sales_Holiday",
    round(AVG(CASE WHEN "Holiday_Flag" = 0 THEN "Average_Weekly_Sales" END),2) AS "Average_Weekly_Sales_Non_Holiday",
	round(AVG(CASE WHEN "Holiday_Flag" = 1 THEN "Average_Weekly_Sales" END) - AVG(CASE WHEN "Holiday_Flag" = 0 THEN "Average_Weekly_Sales" END),2) as holiday_sales_impact
from temp_sales_holiday
GROUP BY
	"Store"
order by 
	"Store";


