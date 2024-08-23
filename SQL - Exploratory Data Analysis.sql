/*EXPLORATORY DATA ANALYSIS USING SQL*/

/*SQL SKILLS: joins, date manipulation, regular expressions, views, stored procedures, aggregate functions, string manipulation*/
 
-- --------------------------------------------------------------------------------------------------------------

/*What are the most common sentiments expressed by time*/
SELECT 
    *
FROM
    ig_clone.users
ORDER BY created_at asc
LIMIT 10;
-- --------------------------------------------------------------------------------------------------------------

/*Are there specific car models or features that frequently lead to negative sentiment*/
How does customer sentiment correlate with safety recalls or other product issues?
Can we identify patterns in customer sentiment over time (e.g., seasonal trends, changes after product updates)?
