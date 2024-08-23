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

/*Can we identify patterns in dealer sentiment over time (e.g., seasonal trends)?*/
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
