-- COPY raw_walmart
-- FROM '/path/Walmart.csv'
-- DELIMITER ','
-- CSV HEADER;

update raw_walmart
set "Date" = TO_CHAR(TO_DATE("Date", 'DD-MM-YYYY'), 'YYYY-MM-DD')



