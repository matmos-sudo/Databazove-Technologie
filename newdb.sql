-- Active: 1790064242236@@127.0.0.1@5432@retail_sales
CREATE DATABASE retail_sales;
CREATE TABLE IF NOT EXISTS orders(
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ship_mode VARCHAR (30) NOT NULL,
    sales DECIMAL(10,2) NOT NULL,
    profit DECIMAL (10,2) NOT NULL

);
ALTER DATABASE "retail_sales" SET datestyle TO "ISO, MDY";
DROP DATABASE retail_sales;

ALTER TABLE public.orders
ALTER COLUMN order_id TYPE VARCHAR(50) 
USING order_id::VARCHAR;

SELECT * FROM orders;

/*7*/
CREATE PROCEDURE get_customer_sale(
    p_customer_id VARCHAR(50)
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    total_sale NUMERIC(10,2);
BEGIN
    SELECT SUM(sales) INTO total_sale FROM orders WHERE customer_id = p_customer_id;
    RAISE NOTICE 'Customer % has total of %', p_customer_id, total_sale;

END;
$procedure$;
CALL get_customer_sale('CUST00001');

/*8*/
CREATE PROCEDURE apply_regional_discount(
    region_name VARCHAR(20),
    discount_rate DECIMAL(1,2)
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE orders SET sales = sales * (1 - discount_rate) WHERE region = region_name;
    RAISE NOTICE 'Region % discount %', region_name, discount_rate;

END;
$procedure$;
SELECT sales FROM orders ORDER BY sales ASC;
CALL apply_regional_discount('West',0.10);
SELECT sales FROM orders ORDER BY sales ASC;
/*9*/
CREATE PROCEDURE get_sales_between(
    start_date DATE,
    end_date DATE
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    vysledok NUMERIC(10,2);
BEGIN
    SELECT SUM(sales) INTO vysledok FROM orders WHERE order_date > '2024-01-01' AND order_date < '2024-03-31';
    RAISE NOTICE 'Start date % end date % sum %', start_date, end_date, vysledok;
END;
$procedure$;

DROP PROCEDURE get_sales_between;

CALL get_sales_between('2024-01-01','2024-03-31')