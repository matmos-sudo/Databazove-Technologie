-- Active: 1790064242236@@127.0.0.1@5432@datacraftinglab_db
-- Active: 1790064242236@@127.0.0.1@5432@postgres

/* 
DB SETUP START
*/
CREATE DATABASE datacraftinglab_db;

CREATE TABLE IF NOT EXISTS flourmills_sales (
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

);

SELECT * FROM flourmills_sales;
/*
DB SETUP END
----------------
DB EXERCISES START
*/
/*1.*/
SELECT product_name, total_amount FROM flourmills_sales WHERE total_amount > (SELECT AVG(total_amount) FROM flourmills_sales);
/*2.*/
SELECT * FROM flourmills_sales WHERE product_category LIKE (SELECT product_category AS amount FROM flourmills_sales GROUP BY product_category ORDER BY SUM(total_amount) DESC LIMIT 1) ORDER BY sales_id ASC LIMIT 5;
/*3.*/
SELECT product_name, total_amount, (SELECT AVG(total_amount)FROM flourmills_sales) AS priemer FROM flourmills_sales;
/*4.*/
SELECT product_name, total_amount, (total_amount/(SELECT SUM(total_amount) FROM flourmills_sales)) AS amount_share FROM flourmills_sales LIMIT 5;
/*5.*/
SELECT * FROM (SELECT EXTRACT(MONTH FROM sales_date) AS mesiac, SUM(total_amount) AS monthly_sales FROM flourmills_sales GROUP BY mesiac) ORDER BY mesiac DESC;
/*6.*/
SELECT * FROM (SELECT product_category, SUM(total_amount) AS total_sales FROM flourmills_sales GROUP BY product_category) WHERE total_sales > 50000000 ORDER BY total_sales DESC;
/*7.*/
SELECT product_name, product_category, total_amount FROM flourmills_sales t1 WHERE t1.total_amount > (SELECT AVG(total_amount) FROM flourmills_sales t2 WHERE t1.product_category = t2.product_category);
/*8.*/
SELECT t1.product_name, t1.region, t1.total_amount, (SELECT MIN(t2.total_amount) AS region_min_amount FROM flourmills_sales t2 WHERE t2.region = t1.region) FROM flourmills_sales t1 LIMIT 5;
/*9.*/
SELECT t1.*
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_name = t1.product_name
    HAVING COUNT(DISTINCT EXTRACT(MONTH FROM t2.sales_date)) > 1
);
/*10.*/
SELECT product_category, product_name, total_amount FROM flourmills_sales t1 WHERE EXISTS (SELECT 1 FROM flourmills_sales t2 WHERE t1.product_category = t2.product_category AND t2.total_amount > 200000);
/*11.*/
SELECT DISTINCT t1.product_category FROM flourmills_sales t1 WHERE EXISTS (SELECT 1 FROM flourmills_sales t2 WHERE t1.product_category = t2.product_category HAVING COUNT(DISTINCT t2.region) > 3);
/*12.*/
SELECT t1.*
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t1.region = t2.region
      AND EXTRACT(YEAR FROM t2.sales_date) = 2024
);
/*13.*/
SELECT DISTINCT t1.product_category
FROM flourmills_sales t1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t1.product_category = t2.product_category
      AND t2.total_amount > 500000
);
/*14.*/
SELECT DISTINCT t1.region
FROM flourmills_sales t1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t1.region = t2.region
      AND t2.product_category = 'Flour'
);