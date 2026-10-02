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