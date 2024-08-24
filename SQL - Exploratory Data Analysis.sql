/*EXPLORATORY DATA ANALYSIS USING SQL*/

/*SQL SKILLS: joins, date manipulation, regular expressions, views, stored procedures, aggregate functions, string manipulation*/
 
-- --------------------------------------------------------------------------------------------------------------

/*What are the most common sentiments expressed by Dealer*/
SELECT 
   d.Dealer_Name,
   s.Sentiment,
   count(*) as Dealer_Sen
FROM Dealers d JOIN
Sentiment s ON d.Zip_Code = s.Postal_Code
GROUP BY d.Dealer_Name, s.Sentiment
ORDER BY count(*);
-- --------------------------------------------------------------------------------------------------------------

/*Are there specific Dealer that frequently lead to negative sentiment by Year*/
with Count_Sentiment as
(
SELECT 
   Year,
   Postal_Code,
   count(*) as CountSentiment,
   DENSE_RANK() OVER (PARTITION BY Year ORDER BY count(*) Desc, Postal_Code Desc) as rank
FROM
    Sentiment
WHERE
	Sentiment='Negative'
GROUP BY
	Year,
	Postal_Code
)
SELECT 
   d.Dealer_Name,
   c.Year,
   c.CountSentiment
FROM Dealers d JOIN
Count_Sentiment c ON d.Zip_Code = c.Postal_Code
wHERE rank = 1
ORDER BY Year;
-- --------------------------------------------------------------------------------------------------------------

/*Can we identify patterns in dealer negative sentiment over time (e.g., seasonal trends)?*/
DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';
 
-- select the category names
SELECT 
    @columns+=QUOTENAME(Dealer_Name) + ','
FROM 
   [Dealers]
ORDER BY 
    Dealer_Name;
 
-- remove the last comma
SET @columns = LEFT(@columns, LEN(@columns) - 1);
 
-- construct dynamic SQL
SET @sql ='
SELECT * FROM   
(
   SELECT
         d.Dealer_Name DealerName ,
         month(s.Date) Month ,
		 s.Year,
		 count (*) Sales
  FROM [Dealers] d
  RIGHT OUTER JOIN [Sentiment] s on d.Zip_Code = s.Postal_Code
  AND s.Sentiment= ''Negative''
  GROUP BY d.Dealer_Name, month(s.Date), s.Year
) 
t 
PIVOT(
    sum (Sales) for  DealerName in ('+ @columns +')
) AS pivot_table;';
 
-- execute the dynamic SQL
EXECUTE sp_executesql @sql;
-- --------------------------------------------------------------------------------------------------------------

/*Which car models are the most popular by Year (Average Sales)*/
with car_model as
(SELECT 
	s.Year,
	m.Model,
	AVG(s.Profit/s.Quantity_Sold) as Avg_Model,
	RANK() OVER (PARTITION BY Year ORDER BY AVG(s.Profit/s.Quantity_Sold) Desc) as rank

FROM Sales_Model s LEFT OUTER JOIN Models m
ON s.Model_ID = m.Car_ID
GROUP BY s.Year, m.Model
)

SELECT Year, Model, Avg_Model
FROM car_model
WHERE rank = 1;
-- --------------------------------------------------------------------------------------------------------------

/*How do sales correlate between models and dealers?*/
DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';
SELECT 
    @columns+=QUOTENAME(Model) + ','
FROM 
   [Models]
ORDER BY 
    Model;
SET @columns = LEFT(@columns, LEN(@columns) - 1);
SET @sql ='
SELECT * FROM   
(
	SELECT 
		d.Dealer_Name,
		m.Model Model,
		AVG(s.Profit/s.Quantity_Sold) as Avg_Model
	FROM Sales_Model s LEFT OUTER JOIN Models m
	ON s.Model_ID = m.Car_ID
	LEFT OUTER JOIN Dealers d
	ON d.Dealer_ID = s.Dealer_ID
	GROUP BY d.Dealer_Name, m.Model
) 
t 
PIVOT(
    sum (Avg_Model) for  Model in ('+ @columns +')
) AS pivot_table;';
EXECUTE sp_executesql @sql;
-- --------------------------------------------------------------------------------------------------------------

/*Which car dealers are the most popular by Year (Average Sales)*/
with car_dealer as
(SELECT 
	s.Year,
	d.Dealer_Name,
	AVG(s.Profit/s.Quantity_Sold) as Avg_Model,
	RANK() OVER (PARTITION BY s.Year ORDER BY AVG(s.Profit/s.Quantity_Sold) Desc) as rank

FROM Sales_Model s LEFT OUTER JOIN Dealers d
ON s.Dealer_ID = d.Dealer_ID
GROUP BY s.Year, d.Dealer_Name
)

SELECT Year, Dealer_name, Avg_Model
FROM car_dealer
WHERE rank = 1;
-- --------------------------------------------------------------------------------------------------------------

/*Identify patterns in Dealers with Average Sales over time (e.g., seasonal trends)?*/
DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';
SELECT 
    @columns+=QUOTENAME(Dealer_Name) + ','
FROM 
   [Dealers]
ORDER BY 
    Dealer_Name;
SET @columns = LEFT(@columns, LEN(@columns) - 1);
SET @sql ='
SELECT * FROM   
(
   SELECT
         d.Dealer_Name DealerName ,
         month(s.Date) Month ,
		 s.Year,
		 AVG(s.Profit/s.Quantity_Sold) Sales
  FROM [Dealers] d
  RIGHT OUTER JOIN [Sales_Model] s on d.Dealer_ID = s.Dealer_ID
  GROUP BY d.Dealer_Name, month(s.Date), s.Year
) 
t 
PIVOT(
    sum (Sales) for  DealerName in ('+ @columns +')
) AS pivot_table;';
EXECUTE sp_executesql @sql;
-- --------------------------------------------------------------------------------------------------------------

/*Identify patterns in Models with Average Sales over time (e.g., seasonal trends)?*/
DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';
SELECT 
    @columns+=QUOTENAME(Model) + ','
FROM 
   [Models]
ORDER BY 
    Model;
SET @columns = LEFT(@columns, LEN(@columns) - 1);
SET @sql ='
SELECT * FROM   
(
   SELECT
         m.Model ModelName ,
         month(s.Date) Month ,
		 s.Year,
		 AVG(s.Profit/s.Quantity_Sold) Sales
  FROM [Models] m
  RIGHT OUTER JOIN [Sales_Model] s on m.Car_ID = s.Model_ID
  GROUP BY m.Model, month(s.Date), s.Year
) 
t 
PIVOT(
    sum (Sales) for  ModelName in ('+ @columns +')
) AS pivot_table;';
EXECUTE sp_executesql @sql;
-- --------------------------------------------------------------------------------------------------------------

/*Can we identify any factors that contribute between dealers and car models?*/
-- Day to Make Sale
DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';
SELECT 
    @columns+=QUOTENAME(Model) + ','
FROM 
   [Models]
ORDER BY 
    Model;
SET @columns = LEFT(@columns, LEN(@columns) - 1);
SET @sql ='
SELECT * FROM   
(
   SELECT
         m.Model ModelName ,
         d.Dealer_Name DealerName ,
		 AVG(s.Days_to_Make_Sale) Avg_Day
  FROM Daily_Sales s
  LEFT OUTER JOIN [Models] m ON m.Car_ID = s.Car_ID
  LEFT OUTER JOIN [Dealers] d ON s.Dealer_ID = d.Dealer_ID
  GROUP BY m.Model, d.Dealer_Name
) 
t 
PIVOT(
    sum (Avg_Day) for  ModelName in ('+ @columns +')
) AS pivot_table;';
EXECUTE sp_executesql @sql;
-- --------------------------------------------------------------------------------------------------------------

/*What types of system affected to recalls are most common?*/
SELECT 
	System_Affected,
	avg(Units) Avg_Units
FROM Recalls
GROUP BY System_Affected
ORDER BY avg(Units) DESC
/*What types of system affected to recalls are most by years?*/
with avgbyyear as
(SELECT 
	YEAR(Date) Year,
	System_Affected,
	avg(Units) Avg_Units,
	RANK() OVER (PARTITION BY YEAR(Date) ORDER BY AVG(Units) Desc) as rank
FROM Recalls
GROUP BY YEAR(Date), System_Affected
)
SELECT Year, System_Affected, Avg_Units
FROM avgbyyear
WHERE rank = 1
-- --------------------------------------------------------------------------------------------------------------

/*How do system affected to recall of Model most common by Years?*/
--by top 3 Model
WITH CTE AS
(SELECT 
	YEAR(Date) Year,
	Model,
	System_Affected,
	avg(Units) Avg_Units,
	ROW_NUMBER() OVER (PARTITION BY YEAR(Date) ORDER BY AVG(Units) Desc) as rank
FROM Recalls
GROUP BY YEAR(Date), Model, System_Affected
)
SELECT Year, Model, System_Affected, Avg_Units
FROM CTE
WHERE rank in (1,2,3)
ORDER BY Year;
-- --------------------------------------------------------------------------------------------------------------

/*Are there any factors (e.g., location, training, resources) that contribute to dealer success or failure?*/
SELECT
	d.City,
	m.Model,
	s.Weather_Condition,
	SUM(s.Count) Sales
FROM Daily_Sales s LEFT JOIN Dealers d
ON s.Dealer_ID = d.Dealer_ID
LEFT JOIN Models m ON s.Car_ID = m.Car_ID
GROUP BY d.City, s.Weather_Condition, m.Model
ORDER BY SUM(s.Count) Desc
-- --------------------------------------------------------------------------------------------------------------

/*Can we identify best condition for dealer making sale?*/
WITH best_cond as
(SELECT TOP 1
	sum(Count) volumns, Weather_Condition, 
	Fog, Rain, Snow
FROM Daily_Sales
GROUP BY Weather_Condition, Fog, Rain, Snow
ORDER BY SUM(Count) Desc)

SELECT d.Dealer_Name, avg(s.Days_to_Make_Sale) Day_Sales
FROM Daily_Sales s, Dealers d, best_cond b
WHERE d.Dealer_ID = s.Dealer_ID
AND s.Weather_Condition = b.Weather_Condition
AND s.Fog = b.Fog
AND s.Rain = b.Rain
AND s.Snow = b.Snow
GROUP BY d.Dealer_Name
ORDER BY avg(s.Days_to_Make_Sale) Asc;
