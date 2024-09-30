#  perform time series analysis by analysing sales data by year and month to understand the seasonality and variation 
# sales by Month and Year

SELECT ProductName,
    strftime('%Y', OrderDate) AS year, 
    strftime('%m', OrderDate) AS month,
    SUM(ProductCost * ProductPrice ) AS total_sales
FROM FactSales
JOIN DimProducts USING (ProductKey)
GROUP BY ProductName
ORDER BY total_sales DESC;

# Sales Variation
SELECT ProductName,
    strftime('%Y', OrderDate) AS year, 
    strftime('%m', OrderDate) AS month,
    AVG(ProductCost * ProductPrice ) AS avg_monthly_sales
FROM FactSales
JOIN DimProducts USING (ProductKey)
GROUP BY ProductName
ORDER BY avg_monthly_sales DESC;

# sales variation across months:
SELECT ProductName,
    strftime('%Y', OrderDate) AS year, 
    strftime('%m', OrderDate) AS month,
    MAX(ProductCost * ProductPrice ) - MIN(ProductCost * ProductPrice ) AS sales_variation
FROM FactSales
JOIN DimProducts USING (ProductKey)
GROUP BY ProductName
ORDER BY sales_variation DESC;

# identify trends and patterns to discover the top performing  product, and region based on sales in 2015,july 2016 and september 2017


SELECT 
    ProductName, 
    Region,
    SUM(ProductCost * ProductPrice ) AS total_sales,
    strftime('%Y', OrderDate) AS year,
    strftime('%m', OrderDate) AS month
FROM FactSales f
JOIN
DimTerritories T ON f.TerritoryKey = T.SalesTerritoryKey
JOIN DimProducts USING (ProductKey)
WHERE 
    (strftime('%Y', OrderDate) = '2015') OR
    (strftime('%Y-%m', OrderDate) = '2016-07') OR
    (strftime('%Y-%m', OrderDate) = '2017-09')
GROUP BY ProductName, region, year, month
ORDER BY total_sales DESC;

# Analze customer demographics and purchasing patterns to understand customer behaviour 

 # Total Purchases by Gender

 SELECT 
    gender,
    SUM(ProductCost * ProductPrice ) AS total_spent,
    COUNT(OrderDate) AS total_purchases
FROM DimCustomer c
JOIN FactSales f  ON c.CustomerKey = f.CustomerKey
 JOIN DimProducts USING (ProductKey)
GROUP BY gender;

# Average Purchase Amount by Age Group

 SELECT
    gender,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+'
    END AS age_group,
    Region,
    COUNT(OrderDate) AS total_purchases,
    SUM(ProductCost * ProductPrice) AS total_spent,
    AVG(ProductCost * ProductPrice ) AS avg_purchase_value
FROM DimCustomer c
JOIN FactSales f  ON c.CustomerKey = f.CustomerKey
JOIN DimProducts USING (ProductKey)
JOIN DimTerritories (TerritoryKey) 
GROUP BY gender, age_group, Region;


# perform customer segmentation based on purchasing or spending using sql 
# Segment Customers by Total Spending
SELECT  
    FirstName, 
    SUM(ProductCost * ProductPrice) AS total_spent,
    CASE
        WHEN SUM(ProductCost * ProductPrice) > 1000 THEN 'High Spender'
        WHEN SUM(ProductCost * ProductPrice) BETWEEN 500 AND 1000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_segment
FROM FactSales f
JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
JOIN DimProducts USING (ProductKey)
GROUP BY 1
ORDER BY total_spent DESC;

# In this query:

# Customers who have spent over $1000 are classified as High Spenders.
# Those who have spent between $500 and $1000 are classified as Medium Spenders.
# Those with spending below $500 are classified as Low Spenders.

# Segment Customers by Purchase Frequency

SELECT
FirstName, 
    COUNT(OrderDate) AS total_purchases,
    CASE
        WHEN COUNT(OrderDate) >= 5 THEN 'Frequent Buyer'
        WHEN COUNT(OrderDate) BETWEEN 2 AND 4 THEN 'Occasional Buyer'
        ELSE 'One-Time Buyer'
    END AS frequency_segment
	FROM FactSales f
JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
JOIN DimProducts USING (ProductKey)
GROUP BY 1
ORDER BY total_purchases DESC;

# In this query:

# Customers who made 5 or more purchases are classified as Frequent Buyers.
# Those with 2-4 purchases are Occasional Buyers.
# Those with 1 purchase are One-Time Buyers.

#  Segment Customers by Recency (RFM Analysis)
SELECT  FirstName, 
    MAX(OrderDate) AS last_purchase_date,
    CASE
        WHEN MAX(OrderDate) >= date('now', '-30 days') THEN 'Active'
        WHEN MAX(OrderDate) BETWEEN date('now', '-90 days') AND date('now', '-30 days') THEN 'Lapsed'
        ELSE 'Dormant'
    END AS recency_segment
 FROM FactSales f
JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
JOIN DimProducts USING (ProductKey)
GROUP BY 1
ORDER BY last_purchase_date DESC;

# In this query:

# Active customers made purchases within the last 30 days.
# Lapsed customers made their last purchase between 30-90 days ago.
# Dormant customers made their last purchase more than 90 days ago.

 
 
 
 