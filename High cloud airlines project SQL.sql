create database airlines_database;

use airlines_database;

show tables;

desc maindata;

explain maindata;

select count(*) from maindata;

select * from maindata;

alter table maindata rename column `%Airline ID` to `Airline_ID`;
alter table maindata rename column `%Carrier Group ID` to `Carrier_Group_ID`;
alter table maindata rename column `# Transported Passengers` to `Transported_Passengers`;
alter table maindata rename column `# Available Seats` to `Available_Seats`;
alter table maindata rename column `%Distance Group ID` to `Distance_Group_ID`;
alter table maindata rename column `Carrier Name` to `Carrier_Name`;
alter table maindata rename column `From - To City` to `From_To_City`;
alter table maindata rename column `Destination Country` to `Destination_Country`;
alter table maindata rename column `Destination State` to `Destination_State`;
alter table maindata rename column `Month (#)` to `Month`;
alter table maindata rename column `Destination City` to `Destination_City`;
alter table maindata rename column `Origin Country` to `Origin_Country`;
alter table maindata rename column `Origin State` to `Origin_State`;
alter table maindata rename column `Origin City` to `Origin_City`;
select year,Month,Day from maindata;

-- Alter the table to add a new column for the date
alter table maindata add column date_column date;

-- using safe update mode to update a table
set sql_safe_updates=0;

-- Date coloumn
update maindata set date_column = date(CONCAT(year, '-', month, '-', day));

select date_column from maindata; 

-- Month name
alter table maindata add column Month_name char(9);
update maindata set month_name = monthname(date_column);

-- Quater
alter table maindata add column Quarter_column varchar(2);
update maindata set Quarter_column = quarter(date_column);

-- YearMonth
alter table maindata add column YearMonth varchar(8);
update maindata set YearMonth = date_format(date_column,'%Y %b');

-- Weekday_No 
alter table maindata add column Weekday_No Int;
update maindata set Weekday_No = IF(DAYOFWEEK(date_column) = 1, 7, DAYOFWEEK(date_column) - 1);

-- Week_day_Name 
alter table maindata add column Week_day_Name VARCHAR(9);
UPDATE maindata
SET Week_day_Name = CASE
    WHEN DAYOFWEEK(date_column) = 1 THEN 'Sunday'
    WHEN DAYOFWEEK(date_column) = 2 THEN 'Monday'
    WHEN DAYOFWEEK(date_column) = 3 THEN 'Tuesday'
    WHEN DAYOFWEEK(date_column) = 4 THEN 'Wednesday'
    WHEN DAYOFWEEK(date_column) = 5 THEN 'Thursday'
    WHEN DAYOFWEEK(date_column) = 6 THEN 'Friday'
    ELSE 'Saturday'
END;

-- Financial_Month 
alter table maindata add column Financial_Month int;
UPDATE maindata
SET Financial_Month = 
    CASE 
        WHEN MONTH(date_column) >= 4 THEN MONTH(date_column) - 3
        ELSE MONTH(date_column) + 9
    END;

select year,month,day,date_column,Month_name,quarter_column,YearMonth,Weekday_No,Week_day_Name,Financial_Month from maindata;

-- Financial quater
ALTER TABLE maindata ADD COLUMN Financial_Quarter varchar(2);
UPDATE maindata
SET Financial_Quarter = 
    CASE 
        WHEN month BETWEEN 1 AND 3 THEN 'Q1'
        WHEN month BETWEEN 4 AND 6 THEN 'Q2'
        WHEN month BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END;
--    Year,Monthno,Monthfullname,Quarter(Q1,Q2,Q3,Q4),YearMonth ( YYYY-MMM),Weekdayno,Weekdayname,FinancialMOnth,Financial Quarter 
SELECT 
    year,
    month,
    day,
    date_column,
    Month_name,
    quarter_column,
    YearMonth,
    Weekday_No,
    Week_day_Name,
    Financial_Month,
    Financial_Quarter
FROM
    maindata;
    
    
    use airlines_database;
select * from maindata;
desc maindata;

-- 2. load Factor by  yearly , Quarterly , Monthly 

SELECT 
    YEAR(date_column) AS Year,
    QUARTER(date_column) AS Quarter,
    month AS Month,
    SUM(Transported_Passengers) AS Total_Transported_Passengers,
    SUM(Available_Seats) AS Total_Available_Seats,
    CONCAT(TRUNCATE(SUM(Transported_Passengers) / SUM(Available_Seats) * 100,2),'%') AS Load_Factor_Percentage
FROM 
    maindata
GROUP BY 
    YEAR(date_column), QUARTER(date_column),month
    ORDER BY 
    YEAR(date_column), QUARTER(date_column),month;

-- 3 Load factor by carrier name
SELECT 
    Carrier_Name,
ifnull(concat(round(avg(Transported_Passengers/Available_Seats)*100,2),"%"),0) as load_factor_percentage from maindata group by Carrier_Name order by load_factor_percentage desc 
limit 10;

-- 4.Top 10 Carrier Names based passengers preference 

SELECT 
    Carrier_Name,
    SUM(Transported_Passengers) AS Total_Passengers
FROM
    maindata
GROUP BY Carrier_Name
ORDER BY Total_Passengers DESC
LIMIT 10;

-- 5 Top 10 routes 

SELECT 
     From_To_City, COUNT(From_To_City) AS No_of_Flights
FROM
    maindata
GROUP BY From_To_City
ORDER BY COUNT(From_To_City) DESC 
limit 10;

-- 6 load factor by Weekend vs Weekdays.

SELECT 
    CASE WHEN DAYOFWEEK(date_column) IN (2, 3, 4, 5, 6) THEN 'Weekday' ELSE 'Weekend' END AS Day_Type,
    concat(round(Avg(Transported_Passengers / Available_Seats) * 100,2),'%') AS Avg_Load_Factor 
FROM 
    maindata
GROUP BY 
    CASE WHEN DAYOFWEEK(date_column) IN (2, 3, 4, 5, 6) THEN 'Weekday' ELSE 'Weekend' END;

-- 7 number of flights based on Distance group
SELECT 
    Distance_Group_ID,
    COUNT(Airline_id) AS Number_of_Flights
FROM 
    maindata 
GROUP BY 
    Distance_Group_ID 
ORDER BY 
    Distance_Group_ID;
    
-- search flights
SELECT 
    *
FROM 
    maindata 
WHERE 
    Origin_Country = 'United States' AND 
    Origin_State = 'Alaska' AND 
    Origin_City = 'Red Dog, AK' AND 
    Destination_Country = 'United States' AND 
    Destination_State = 'Alaska' AND 
    Destination_City = 'Kotzebue, AK';

