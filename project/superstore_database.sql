-- =====================================================================
--  Superstore Sales Database  |  MySQL 8.0+
--  Part 1: database + table creation (PKs, FKs, constraints)
--  Part 2: SQL reporting queries (11 queries)
--  Tables are loaded by ETL_Pipeline.ipynb (Pandas -> MySQL).
-- =====================================================================

CREATE DATABASE IF NOT EXISTS superstore_db CHARACTER SET utf8mb4;
USE superstore_db;

-- ---------------------------------------------------------------------
-- PART 1: SCHEMA
-- ---------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS order_returns;
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS regions;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE regions (
    region_id     INT          NOT NULL,
    region_name   VARCHAR(20)  NOT NULL,
    manager_name  VARCHAR(60),
    CONSTRAINT pk_regions PRIMARY KEY (region_id),
    CONSTRAINT uq_region_name UNIQUE (region_name)
) ENGINE = InnoDB;

CREATE TABLE locations (
    location_id   INT          NOT NULL,
    city          VARCHAR(60)  NOT NULL,
    state         VARCHAR(40)  NOT NULL,
    postal_code   CHAR(5),
    country       VARCHAR(40)  NOT NULL,
    region_id     INT          NOT NULL,
    CONSTRAINT pk_locations PRIMARY KEY (location_id),
    CONSTRAINT uq_location UNIQUE (city, state, postal_code),
    CONSTRAINT fk_locations_region FOREIGN KEY (region_id) REFERENCES regions (region_id)
) ENGINE = InnoDB;

CREATE TABLE customers (
    customer_id    VARCHAR(10) NOT NULL,
    customer_name  VARCHAR(80) NOT NULL,
    segment        VARCHAR(20) NOT NULL,
    customer_tier  VARCHAR(10) NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT chk_segment CHECK (segment IN ('Consumer', 'Corporate', 'Home Office')),
    CONSTRAINT chk_tier CHECK (customer_tier IN ('Gold', 'Silver', 'Bronze'))
) ENGINE = InnoDB;

CREATE TABLE products (
    product_id      VARCHAR(20)   NOT NULL,
    product_name    VARCHAR(200)  NOT NULL,
    category        VARCHAR(30)   NOT NULL,
    sub_category    VARCHAR(30)   NOT NULL,
    avg_list_price  DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT chk_list_price CHECK (avg_list_price > 0)
) ENGINE = InnoDB;

CREATE TABLE orders (
    order_id     VARCHAR(20) NOT NULL,
    customer_id  VARCHAR(10) NOT NULL,
    location_id  INT         NOT NULL,
    order_date   DATE        NOT NULL,
    ship_date    DATE        NOT NULL,
    ship_mode    VARCHAR(20) NOT NULL,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    CONSTRAINT fk_orders_location FOREIGN KEY (location_id) REFERENCES locations (location_id),
    CONSTRAINT chk_ship_after_order CHECK (ship_date >= order_date),
    CONSTRAINT chk_ship_mode CHECK (ship_mode IN ('Same Day', 'First Class', 'Second Class', 'Standard Class'))
) ENGINE = InnoDB;

CREATE TABLE order_details (
    order_detail_id  INT           NOT NULL,
    order_id         VARCHAR(20)   NOT NULL,
    product_id       VARCHAR(20)   NOT NULL,
    quantity         INT           NOT NULL,
    discount         DECIMAL(4,2)  NOT NULL,
    sales            DECIMAL(12,4) NOT NULL,
    profit           DECIMAL(12,4) NOT NULL,
    CONSTRAINT pk_order_details PRIMARY KEY (order_detail_id),
    CONSTRAINT fk_od_order FOREIGN KEY (order_id) REFERENCES orders (order_id),
    CONSTRAINT fk_od_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_discount CHECK (discount >= 0 AND discount <= 1),
    CONSTRAINT chk_sales CHECK (sales > 0)
) ENGINE = InnoDB;

CREATE TABLE order_returns (
    order_id  VARCHAR(20) NOT NULL,
    CONSTRAINT pk_order_returns PRIMARY KEY (order_id),
    CONSTRAINT fk_returns_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- PART 2: SQL REPORTING QUERIES
-- ---------------------------------------------------------------------

-- Q1. Sales, profit and margin by category
-- Question: Which product category generates the most revenue and how profitable is each one?
SELECT p.category,
       COUNT(DISTINCT od.order_id)                           AS orders,
       SUM(od.quantity)                                      AS units_sold,
       ROUND(SUM(od.sales), 2)                               AS total_sales,
       ROUND(SUM(od.profit), 2)                              AS total_profit,
       ROUND(100 * SUM(od.profit) / SUM(od.sales), 2)        AS profit_margin_pct,
       ROUND(100 * SUM(od.sales) / (SELECT SUM(sales) FROM order_details), 2) AS sales_share_pct
FROM order_details od
JOIN products p ON p.product_id = od.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- Q2. Monthly revenue and number of orders
-- Question: How do revenue and order volume trend month by month?
SELECT DATE_FORMAT(o.order_date, '%Y-%m')   AS order_month,
       COUNT(DISTINCT o.order_id)           AS orders,
       ROUND(SUM(od.sales), 2)              AS revenue,
       ROUND(SUM(od.profit), 2)             AS profit
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

-- Q3. Top 10 customers by revenue
-- Question: Which customers contribute the most revenue?
SELECT c.customer_id,
       c.customer_name,
       c.segment,
       c.customer_tier,
       COUNT(DISTINCT o.order_id)  AS orders,
       ROUND(SUM(od.sales), 2)     AS total_revenue,
       ROUND(SUM(od.profit), 2)    AS total_profit
FROM customers c
JOIN orders o         ON o.customer_id = c.customer_id
JOIN order_details od ON od.order_id   = o.order_id
GROUP BY c.customer_id, c.customer_name, c.segment, c.customer_tier
ORDER BY total_revenue DESC
LIMIT 10;

-- Q4. Sales and profitability by region (with regional manager)
-- Question: Which region sells the most, and which is the most profitable?
SELECT r.region_name,
       r.manager_name,
       COUNT(DISTINCT o.order_id)                        AS orders,
       ROUND(SUM(od.sales), 2)                           AS total_sales,
       ROUND(SUM(od.profit), 2)                          AS total_profit,
       ROUND(100 * SUM(od.profit) / SUM(od.sales), 2)    AS profit_margin_pct
FROM regions r
JOIN locations l      ON l.region_id   = r.region_id
JOIN orders o         ON o.location_id = l.location_id
JOIN order_details od ON od.order_id   = o.order_id
GROUP BY r.region_name, r.manager_name
ORDER BY total_sales DESC;

-- Q5. Average order value by customer segment
-- Question: How much is an average order worth in each customer segment?
SELECT c.segment,
       COUNT(*)                         AS orders,
       ROUND(AVG(t.order_total), 2)     AS avg_order_value,
       ROUND(MAX(t.order_total), 2)     AS largest_order
FROM (SELECT order_id, SUM(sales) AS order_total
      FROM order_details
      GROUP BY order_id) t
JOIN orders o    ON o.order_id    = t.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.segment
ORDER BY avg_order_value DESC;

-- Q6. Products with sales above the average product
-- Question: Which products sell better than the average product?
SELECT p.product_id,
       p.product_name,
       p.category,
       ROUND(SUM(od.sales), 2) AS total_sales
FROM products p
JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING SUM(od.sales) > (SELECT AVG(ps.product_sales)
                        FROM (SELECT SUM(sales) AS product_sales
                              FROM order_details
                              GROUP BY product_id) ps)
ORDER BY total_sales DESC
LIMIT 15;

-- Q7. Sub-category profitability (profitable vs loss-making)
-- Question: Which sub-categories make or lose money? (only sub-categories with at least 3 order lines)
SELECT p.category,
       p.sub_category,
       COUNT(*)                                           AS order_lines,
       ROUND(SUM(od.sales), 2)                            AS total_sales,
       ROUND(SUM(od.profit), 2)                           AS total_profit,
       ROUND(100 * SUM(od.profit) / SUM(od.sales), 2)     AS profit_margin_pct,
       CASE WHEN SUM(od.profit) < 0 THEN 'Loss-making'
            WHEN 100 * SUM(od.profit) / SUM(od.sales) >= 20 THEN 'High margin'
            ELSE 'Profitable' END                         AS status
FROM order_details od
JOIN products p ON p.product_id = od.product_id
GROUP BY p.category, p.sub_category
HAVING COUNT(*) >= 3
ORDER BY total_profit ASC;

-- Q8. Impact of discounts on profit
-- Question: Do heavier discounts hurt profitability?
SELECT CASE WHEN discount = 0     THEN '1. No discount'
            WHEN discount <= 0.20 THEN '2. Low (1-20%)'
            WHEN discount <= 0.40 THEN '3. Medium (21-40%)'
            ELSE                       '4. High (over 40%)' END   AS discount_band,
       COUNT(*)                                                   AS order_lines,
       ROUND(SUM(sales), 2)                                       AS total_sales,
       ROUND(SUM(profit), 2)                                      AS total_profit,
       ROUND(100 * SUM(profit) / SUM(sales), 2)                   AS profit_margin_pct
FROM order_details
GROUP BY discount_band
ORDER BY discount_band;

-- Q9. Return rate by product category
-- Question: Which categories have the most returned orders?
SELECT p.category,
       COUNT(DISTINCT od.order_id)                                              AS orders,
       COUNT(DISTINCT CASE WHEN r.order_id IS NOT NULL THEN od.order_id END)    AS returned_orders,
       ROUND(100 * COUNT(DISTINCT CASE WHEN r.order_id IS NOT NULL THEN od.order_id END)
                 / COUNT(DISTINCT od.order_id), 2)                              AS return_rate_pct
FROM order_details od
JOIN products p           ON p.product_id = od.product_id
LEFT JOIN order_returns r ON r.order_id   = od.order_id
GROUP BY p.category
ORDER BY return_rate_pct DESC;

-- Q10. Shipping performance by ship mode
-- Question: How long does each shipping mode actually take, and how much revenue flows through it?
SELECT o.ship_mode,
       COUNT(DISTINCT o.order_id)                          AS orders,
       ROUND(AVG(DATEDIFF(o.ship_date, o.order_date)), 2)  AS avg_days_to_ship,
       MAX(DATEDIFF(o.ship_date, o.order_date))            AS max_days_to_ship,
       ROUND(SUM(od.sales), 2)                             AS total_sales
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY o.ship_mode
ORDER BY avg_days_to_ship;

-- Q11. Top 3 products in each category (window function)
-- Question: What are the best-selling products inside each category?
WITH ranked AS (
    SELECT p.category,
           p.product_name,
           SUM(od.sales) AS total_sales,
           RANK() OVER (PARTITION BY p.category ORDER BY SUM(od.sales) DESC) AS rnk
    FROM order_details od
    JOIN products p ON p.product_id = od.product_id
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT category, rnk AS sales_rank, product_name, ROUND(total_sales, 2) AS total_sales
FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;
