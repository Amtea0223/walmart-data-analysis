-- COPY raw_walmart
-- FROM '/path/Walmart.csv'
-- DELIMITER ','
-- CSV HEADER;

-- update raw_walmart
-- set "Date" = TO_CHAR(TO_DATE("Date", 'DD-MM-YYYY'), 'YYYY-MM-DD')


--Sales
select 
	"Store",
	"Date", 
 	"Weekly_Sales",
	ROUND( cast(AVG("Weekly_Sales") OVER (Partition by "Store" ORDER BY "Date" ROWS BETWEEN 3 PRECEDING AND 0 FOLLOWING) as numeric),2) AS "4_Weeks_Rolling_Average",
	ROUND( cast(("Weekly_Sales" - LAG("Weekly_Sales", 1) OVER (Partition by "Store" ORDER BY "Date")) / LAG("Weekly_Sales", 1) OVER (ORDER BY "Date") as numeric),2) AS "Weekly_Growth_Rate"
from raw_walmart
order by "Store","Date" asc



