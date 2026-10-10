-- Active: 1790064242236@@127.0.0.1@5432@datacraftinglab_db
/*CREATE TABLE IF NOT EXISTS flourmills_sales (
    sales_id INT PRIMARY KEY,
    sales_date DATE,
    region VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    product_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_id INT,
    quantity_sold INT,
    unit_price DECIMAL(10,2),
    discount_rate INT,
    payment_method VARCHAR(100),
    sales_rep VARCHAR(150),
    warehouse VARCHAR(100),
    delivery_status VARCHAR(100),
    order_channel VARCHAR(100),
    batch_number INT,
    production_date DATE,
    total_amount DECIMAL(10,2)

);*/
/*1*/
WITH daily_sales AS (SELECT SUM(total_amount), sales_date FROM flourmills_sales GROUP BY sales_date HAVING SUM(total_amount) > 3000000) SELECT * FROM daily_sales ORDER BY sum DESC;
/*2*/
WITH category_sales AS (SELECT SUM(total_amount), product_category FROM flourmills_sales GROUP BY product_category) SELECT * FROM category_sales ORDER BY sum DESC;

/*3*/
WITH product_sales_cte AS (
    SELECT product_category, product_name, SUM(total_amount) AS total_product_sales FROM flourmills_sales GROUP BY product_category, product_name
), ranked_sales_cte AS (
    SELECT 
    product_category,
    product_name,
    total_product_sales,
    RANK() OVER(PARTITION BY product_category ORDER BY total_product_sales DESC)AS category_rank FROM product_sales_cte
) SELECT * FROM ranked_sales_cte WHERE category_rank <= 3 ORDER BY product_category, category_rank;

/*4*/
WITH first_cte AS (
    SELECT SUM(total_amount) AS revenue, customer_type FROM flourmills_sales GROUP BY customer_type
),
second_cte AS(
    SELECT first_cte.customer_type, revenue, SUM(revenue) OVER()AS total_revenue, ROUND((revenue * 100.0) / SUM(revenue) OVER(), 2) AS revenue_percentage FROM first_cte
) SELECT * FROM second_cte ORDER BY revenue DESC;

/*5*/
WITH first_cte AS (
    SELECT customer_id, product_name, sales_date, total_amount, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY sales_date DESC) AS ranked FROM flourmills_sales
) SELECT * FROM first_cte WHERE ranked = 1 ORDER BY customer_id ASC;

/*6*/
WITH RECURSIVE cte AS(
    SELECT MIN(sales_date) AS first_val, MAX(sales_date) as last_val FROM flourmills_sales

    UNION ALL

    SELECT first_val + 1, last_val FROM cte WHERE first_val < last_val
)
SELECT * FROM cte;

/*7*/
WITH RECURSIVE first_cte AS (
    SELECT DATE_TRUNC('month',sales_date) AS month, SUM(total_amount) AS revenue FROM flourmills_sales GROUP BY month
), second_cte AS (
    SELECT
    month,
    revenue,
    ROW_NUMBER() OVER(ORDER BY month) AS rn FROM first_cte
), third_cte AS (
    SELECT 
        rn, 
        month, 
        revenue, 
        revenue AS cumulative_revenue 
    FROM second_cte 
    WHERE rn = 1
    
    UNION ALL
 
    SELECT 
        nxt.rn, 
        nxt.month, 
        nxt.revenue, 
        (prev.cumulative_revenue + nxt.revenue) AS cumulative_revenue 
    FROM cumulative_target prev
    JOIN second_cte nxt ON nxt.rn = prev.rn + 1
    WHERE prev.cumulative_revenue < 500000000
)
SELECT * FROM third_cte ORDER BY rn;