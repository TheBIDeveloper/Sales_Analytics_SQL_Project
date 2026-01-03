USE SalesAnalytics;
GO

--------------------------------------------------
-- 1. Total sales per product
--------------------------------------------------
SELECT p.product_name,
       SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

--------------------------------------------------
-- 2. Total sales per category
--------------------------------------------------
SELECT c.category_name,
       SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_sales DESC;

--------------------------------------------------
-- 3. Total sales per customer
--------------------------------------------------
SELECT cu.customer_name,
       SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY cu.customer_name
ORDER BY total_sales DESC;

--------------------------------------------------
-- 4. Top 5 selling products
--------------------------------------------------
SELECT TOP 5 p.product_name,
       SUM(s.quantity) AS total_units_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC;

--------------------------------------------------
-- 5. Sales per country
--------------------------------------------------
SELECT cu.country,
       SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY cu.country
ORDER BY total_sales DESC;

--------------------------------------------------
-- 6. Average purchase value per customer
--------------------------------------------------
SELECT cu.customer_name,
       AVG(s.quantity * p.price) AS avg_purchase_value
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY cu.customer_name
ORDER BY avg_purchase_value DESC;

--------------------------------------------------
-- 7. Total quantity sold per category
--------------------------------------------------
SELECT c.category_name,
       SUM(s.quantity) AS total_quantity
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_quantity DESC;

--------------------------------------------------
-- 8. Customer purchase ranking
--------------------------------------------------
SELECT cu.customer_name,
       SUM(s.quantity * p.price) AS total_sales,
       RANK() OVER (ORDER BY SUM(s.quantity * p.price) DESC) AS sales_rank
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY cu.customer_name
ORDER BY sales_rank;

--------------------------------------------------
-- 9. Monthly sales trend
--------------------------------------------------
SELECT FORMAT(s.sale_date,'yyyy-MM') AS month,
       SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY FORMAT(s.sale_date,'yyyy-MM')
ORDER BY month;

--------------------------------------------------
-- 10. Products sold above average
--------------------------------------------------
SELECT p.product_name,
       SUM(s.quantity) AS total_units
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(s.quantity) > (
    SELECT AVG(total_quantity) FROM (
        SELECT SUM(quantity) AS total_quantity
        FROM sales
        GROUP BY product_id
    ) AS sub
)
ORDER BY total_units DESC;

--------------------------------------------------
-- 11. Top customers by category
--------------------------------------------------
WITH customer_category AS (
    SELECT cu.customer_name,
           c.category_name,
           SUM(s.quantity * p.price) AS total_sales,
           RANK() OVER (PARTITION BY c.category_name ORDER BY SUM(s.quantity * p.price) DESC) AS rnk
    FROM sales s
    JOIN customers cu ON s.customer_id = cu.customer_id
    JOIN products p ON s.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY cu.customer_name, c.category_name
)
SELECT customer_name, category_name, total_sales
FROM customer_category
WHERE rnk = 1;

--------------------------------------------------
-- 12. Highest revenue product per category
--------------------------------------------------
WITH ranked_products AS (
    SELECT p.product_name,
           c.category_name,
           SUM(s.quantity * p.price) AS total_sales,
           RANK() OVER (PARTITION BY c.category_name ORDER BY SUM(s.quantity * p.price) DESC) AS rnk
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY p.product_name, c.category_name
)
SELECT product_name, category_name, total_sales
FROM ranked_products
WHERE rnk = 1;

--------------------------------------------------
-- 13. Total transactions per customer
--------------------------------------------------
SELECT cu.customer_name,
       COUNT(s.sale_id) AS total_transactions
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
GROUP BY cu.customer_name
ORDER BY total_transactions DESC;

--------------------------------------------------
-- 14. Average units per transaction
--------------------------------------------------
SELECT AVG(quantity) AS avg_units_per_transaction
FROM sales;

--------------------------------------------------
-- 15. Products never sold
--------------------------------------------------
SELECT p.product_name
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
WHERE s.product_id IS NULL;

--------------------------------------------------
-- 16. Total revenue by category
--------------------------------------------------
SELECT c.category_name,
       SUM(s.quantity * p.price) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

--------------------------------------------------
-- 17. Top 5 customers by total revenue
--------------------------------------------------
SELECT TOP 5 cu.customer_name,
       SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY cu.customer_name
ORDER BY total_sales DESC;

--------------------------------------------------
-- 18. Daily sales trend
--------------------------------------------------
SELECT s.sale_date,
       SUM(s.quantity * p.price) AS daily_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY s.sale_date
ORDER BY s.sale_date;

--------------------------------------------------
-- 19. Revenue per product per country
--------------------------------------------------
SELECT p.product_name,
       cu.country,
       SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN customers cu ON s.customer_id = cu.customer_id
GROUP BY p.product_name, cu.country
ORDER BY total_sales DESC;

--------------------------------------------------
-- 20. Customer purchase frequency
--------------------------------------------------
SELECT cu.customer_name,
       COUNT(s.sale_id) AS purchase_count
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
GROUP BY cu.customer_name
ORDER BY purchase_count DESC;
