SELECT * FROM retail_store_inventory;

USE [Retail Store Inventory DB];

--1.Which products are top sellers?
SELECT TOP 1 product_id, category, SUM(units_sold) AS Total_units_sold
FROM retail_store_inventory
GROUP BY  product_id, Category
ORDER BY Total_units_sold DESC;

--2.Which stores have the highest sales?
SELECT TOP 1 store_id, SUM(units_sold) AS Total_units_sold
FROM retail_store_inventory
GROUP BY store_id
ORDER BY Total_units_sold DESC;

--3.Which months show highest and lowest demand?
SELECT TOP 1
		MONTH(date) AS Month_Number,
		DATENAME(MONTH, date) AS Month_Name,
		SUM(demand_forecast) AS Highest_demand
FROM retail_store_inventory
GROUP BY MONTH(date), DATENAME(MONTH,date)
ORDER BY Highest_demand DESC;

SELECT TOP 1
		MONTH(date) AS Month_Number,
		DATENAME(MONTH, date) AS Month_Name,
		SUM(demand_forecast) AS Lowest_demand
FROM retail_store_inventory
GROUP BY MONTH(date), DATENAME(MONTH,date)
ORDER BY Lowest_demand ASC;

--4.What is the average inventory level per store?
SELECT store_id, AVG(inventory_level) AS Avg_inventory
FROM retail_store_inventory
GROUP BY store_id
ORDER BY store_id;

--Overall Average (Company-Wide)
SELECT 
    AVG(avg_inventory) AS company_avg_inventory
FROM (
    SELECT store_id, AVG(inventory_level) AS avg_inventory
    FROM retail_store_inventory
    GROUP BY store_id
) AS store_avg;

--Top performing store by category.
SELECT TOP 1 store_id, category, SUM(units_sold) AS Total_units_sold
FROM retail_store_inventory
GROUP BY store_id, category
ORDER BY Total_units_sold DESC;

--5.Total sales per product.
SELECT Product_ID, SUM(Units_Sold) AS Total_Sales
FROM retail_store_inventory
GROUP BY Product_ID
ORDER BY Total_Sales DESC;

--6.Monthly sales trend.
SELECT DATEPART(month, Date) AS Month, 
		SUM(Units_Sold) AS Total_Sales
FROM retail_store_inventory
GROUP BY DATEPART(month, Date)
ORDER BY Month;

--7.Total sales revenue by product.
SELECT product_id, 
		ROUND(SUM(units_sold * price), 2) AS total_revenue
FROM retail_store_inventory
GROUP BY product_id
ORDER BY total_revenue DESC;

--8.Total revenue by store and month.
SELECT store_id,
		MONTH(date) AS Month_Number,
		DATENAME(MONTH, date) AS Month_Name,
		ROUND(SUM(units_sold * price),2) AS Total_Revenue
FROM retail_store_inventory
GROUP BY store_id, MONTH(date), DATENAME(MONTH, date)
ORDER BY Total_Revenue DESC;

--9.Top 5 products with the highest revenue.
SELECT TOP 5 product_id,
		ROUND(SUM(units_sold * price), 2) AS Total_Revenue
FROM retail_store_inventory
GROUP BY product_id
ORDER BY Total_Revenue DESC;

--10.Average daily sales per store.
SELECT store_id, AVG(units_sold) AS Avg_Daily_Sales
FROM retail_store_inventory
GROUP BY store_id
ORDER BY Avg_Daily_Sales;

--11.Products that went out of stock.
SELECT DISTINCT product_id
FROM retail_store_inventory
WHERE inventory_level = 0;

--12.Find reorder recommendations (below threshold).
SELECT 
    product_id, 
    store_id,
    AVG(inventory_level) AS avg_inventory
FROM retail_store_inventory
GROUP BY product_id, store_id
HAVING AVG(inventory_level) < 50;  

--13.Month-over-month sales growth.
SELECT 
    MONTH(date) AS month_number,
    SUM(units_sold) AS total_sales,
    LAG(SUM(units_sold)) OVER (ORDER BY MONTH(date)) AS prev_month_sales,
    (SUM(units_sold) - LAG(SUM(units_sold)) OVER (ORDER BY MONTH(date))) * 100.0 
        / LAG(SUM(units_sold)) OVER (ORDER BY MONTH(date)) AS growth_percent
FROM retail_store_inventory
GROUP BY MONTH(date)
ORDER BY month_number;

--14.Top performing store by category.
WITH ranked_stores AS (
    SELECT 
        category,
        store_id,
        SUM(units_sold) AS total_units,
        RANK() OVER (PARTITION BY category ORDER BY SUM(units_sold) DESC) AS rnk
    FROM retail_store_inventory
    GROUP BY category, store_id
)
SELECT 
    category,
    store_id,
    total_units
FROM ranked_stores
WHERE rnk = 1;


--15.Find slow-moving products (low sales despite high inventory).
SELECT 
    product_id,
    SUM(units_sold) AS total_sales,
    AVG(inventory_level) AS avg_inventory
FROM retail_store_inventory
GROUP BY product_id
HAVING SUM(units_sold) < 100 AND AVG(inventory_level) > 500;

--16.Cumulative sales trend (running total).
SELECT 
    DATEPART(MONTH, date) AS month_number,
    SUM(units_sold) AS monthly_sales,
    SUM(SUM(units_sold)) OVER (ORDER BY DATEPART(MONTH, date)) AS running_total
FROM retail_store_inventory
GROUP BY DATEPART(MONTH, date);


