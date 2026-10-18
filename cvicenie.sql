-- Active: 1790064242236@@127.0.0.1@5432@superstore
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(10,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
SELECT * FROM customers;
SELECT * FROM products;

SELECT * FROM orders;

SELECT orders.order_id, customers.customer_name, orders.sales FROM orders INNER JOIN customers ON customers.customer_id = orders.customer_id WHERE orders.sales > 500;

SELECT orders.order_id, customers.customer_name, products.category, orders.sales FROM orders INNER JOIN customers ON customers.customer_id = orders.customer_id INNER JOIN products ON products.product_id = orders.product_id;

SELECT customers.region, SUM(orders.sales) FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.region;

SELECT products.product_name, SUM(orders.sales) AS hodnota FROM products LEFT JOIN orders ON orders.product_id = products.product_id GROUP BY products.product_name;

SELECT customers.customer_name, orders.order_id, orders.sales FROM customers FULL OUTER JOIN orders ON customers.customer_id = orders.customer_id;

SELECT customers.region, SUM(orders.sales) FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.region;

SELECT customers.customer_name, COUNT(orders.customer_id) AS pocet FROM customers LEFT JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customer.customer_name;

SELECT products.category, AVG(orders.discount) FROM products INNER JOIN orders ON orders.product_id = products.product_id GROUP BY products.category;

SELECT customers.customer_name, SUM(orders.sales) AS celkova_hodnota FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.customer_id, customers.customer_name HAVING SUM(orders.sales) > 2000;

SELECT customers.region, SUM(orders.sales) AS predaj, AVG(orders.discount) AS zlava, COUNT(orders.customer_id) AS pocet FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.region;

SELECT customers.region, COUNT(*) FILTER (WHERE orders.sales > 1000) AS high_value,COUNT(*) FILTER (WHERE orders.sales <= 1000) AS low_value FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.region;

SELECT 
    customers.customer_name,
    SUM(orders.sales) AS celkovy_predaj,
    AVG(orders.discount) AS priemerna_zlava,
    COUNT(orders.order_id) AS pocet_objednavok,
    CASE 
        WHEN SUM(orders.sales) > 2500 THEN 'VIP'
        ELSE 'REGULAR'
    END AS typ_zakaznika
FROM customers
INNER JOIN orders ON orders.customer_id = customers.customer_id
GROUP BY customers.customer_id, customers.customer_name
ORDER BY celkovy_predaj DESC;


/*------------------------------4.Tyzden - 1b------------------------------------*/
WITH RankedOrders AS (
    SELECT 
        c.customer_name,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY o.order_date DESC) AS rn
    FROM 
        customers c
    JOIN 
        orders o ON c.customer_id = o.customer_id
)
SELECT 
    customer_name,
    order_id,
    order_date
FROM 
    RankedOrders
WHERE 
    rn <= 2
ORDER BY 
    customer_name ASC,
    rn ASC;


    WITH CustomerProfit AS (
    SELECT 
        c.region,
        c.customer_name,
        SUM(o.profit) AS total_profit
    FROM 
        customers c
    JOIN 
        orders o ON c.customer_id = o.customer_id
    GROUP BY 
        c.region,
        c.customer_id,
        c.customer_name
)
SELECT 
    region,
    customer_name,
    total_profit,
    RANK() OVER(PARTITION BY region ORDER BY total_profit DESC) AS profit_rank,
    DENSE_RANK() OVER(PARTITION BY region ORDER BY total_profit DESC) AS profit_dense_rank
FROM 
    CustomerProfit
ORDER BY 
    region ASC,
    total_profit DESC;



    WITH CustomerSales AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(o.sales) AS total_sales
    FROM 
        customers c
    JOIN 
        orders o ON c.customer_id = o.customer_id
    GROUP BY 
        c.customer_id,
        c.customer_name
)
SELECT 
    customer_name,
    total_sales,
    NTILE(4) OVER(ORDER BY total_sales DESC) AS quartile
FROM 
    CustomerSales
ORDER BY 
    total_sales DESC;


    WITH MonthlySales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS monthly_sales
    FROM 
        orders
    GROUP BY 
        DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY month) AS prev_month_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY month) AS next_month_sales
FROM 
    MonthlySales
ORDER BY 
    month ASC;



    WITH ProductSales AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(o.sales) AS product_sales
    FROM 
        orders o
    JOIN 
        products p ON o.product_id = p.product_id
    GROUP BY 
        p.category, 
        p.product_name
)
SELECT 
    category,
    product_name,
    product_sales,
    SUM(product_sales) OVER (PARTITION BY category) AS category_total,
    ROUND(
        product_sales * 100.0 / SUM(product_sales) OVER (PARTITION BY category), 
        2
    ) AS pct_of_category
FROM 
    ProductSales;


    WITH CustomerOrderDates AS (
    SELECT DISTINCT
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) OVER (PARTITION BY c.customer_id) AS last_order_date,
        MAX(o.order_date) OVER () AS latest_order_date
    FROM 
        customers c
    JOIN 
        orders o ON c.customer_id = o.customer_id
)
SELECT 
    customer_id,
    customer_name,
    last_order_date
FROM 
    CustomerOrderDates
WHERE 
    last_order_date < latest_order_date - INTERVAL '90 days'
ORDER BY 
    last_order_date ASC;


    WITH MonthlySales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS monthly_sales
    FROM 
        orders
    GROUP BY 
        DATE_TRUNC('month', order_date)
),
SalesWithLag AS (
    SELECT 
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY month) AS prev_month_sales
    FROM 
        MonthlySales
)
SELECT 
    month,
    monthly_sales,
    prev_month_sales,
    monthly_sales - prev_month_sales AS sales_change,
    ROUND(((monthly_sales - prev_month_sales) / prev_month_sales) * 100.0, 2) AS growth_percentage
FROM 
    SalesWithLag
ORDER BY 
    month ASC;


