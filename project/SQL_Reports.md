# SQL Reports: Superstore database

## Q1. Sales, profit and margin by category
*Which product category generates the most revenue and how profitable is each one?*

```sql
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
```

**Result:**

| category        |   orders |   units_sold |   total_sales |   total_profit |   profit_margin_pct |   sales_share_pct |
|:----------------|---------:|-------------:|--------------:|---------------:|--------------------:|------------------:|
| Technology      |       58 |       257.00 |     30,300.49 |       7,332.53 |               24.20 |             40.43 |
| Furniture       |       49 |       246.00 |     22,593.75 |       1,199.75 |                5.31 |             30.15 |
| Office Supplies |      107 |       593.00 |     22,048.72 |       1,297.66 |                5.89 |             29.42 |

## Q2. Monthly revenue and number of orders
*How do revenue and order volume trend month by month?*

```sql
SELECT DATE_FORMAT(o.order_date, '%Y-%m')   AS order_month,
       COUNT(DISTINCT o.order_id)           AS orders,
       ROUND(SUM(od.sales), 2)              AS revenue,
       ROUND(SUM(od.profit), 2)             AS profit
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;
```

**Result:**

| order_month   |   orders |   revenue |    profit |
|:--------------|---------:|----------:|----------:|
| 2015-01       |        1 |      3.93 |      1.33 |
| 2015-03       |        2 |    226.42 |   -438.75 |
| 2015-05       |        6 |  2,153.20 |    380.16 |
| 2015-07       |        4 |  2,797.05 | -3,760.48 |
| 2015-08       |        2 |  1,817.99 |    484.13 |
| 2015-09       |        4 |  1,869.68 |    479.57 |
| 2015-10       |        1 |    107.44 |     10.74 |
| 2015-11       |        6 |  2,173.48 |    631.88 |
| 2015-12       |        5 |  7,424.14 |    654.17 |
| 2016-01       |        2 |    253.80 |     62.27 |
| 2016-02       |        3 |  2,748.60 |  1,290.38 |
| 2016-03       |        2 |    132.82 |     60.73 |
| 2016-04       |        3 |  2,779.92 |  1,017.55 |
| 2016-05       |        1 |  1,745.71 |    209.64 |
| 2016-06       |        1 |  3,184.36 |  1,177.39 |
| 2016-07       |        2 |    363.33 |     65.10 |
| 2016-08       |        1 |  1,203.44 |     66.24 |
| 2016-09       |        7 |  1,920.60 |    431.95 |
| 2016-10       |        2 |    217.51 |     36.07 |
| 2016-11       |        3 |     93.62 |     25.19 |
| 2016-12       |        6 |  1,549.46 |   -205.32 |
| 2017-01       |        2 |    740.84 |    266.93 |
| 2017-03       |        1 |    189.88 |    -94.94 |
| 2017-04       |        3 |  1,481.22 |    262.09 |
| 2017-05       |        4 |    315.15 |     39.46 |
| 2017-06       |        4 |  1,336.55 |    332.66 |
| 2017-07       |        4 |  2,267.93 |    207.74 |
| 2017-08       |        1 |     79.74 |     34.34 |
| 2017-09       |        8 |  3,375.42 |  1,246.34 |
| 2017-10       |        5 |    888.93 |    156.82 |
| 2017-11       |        6 |  2,441.71 |    306.41 |
| 2017-12       |        3 |  2,208.41 |    -38.62 |
| 2018-01       |        2 |  1,959.93 |     44.98 |
| 2018-02       |        2 |    985.89 |   -210.07 |
| 2018-03       |        3 |    899.32 |    124.94 |
| 2018-04       |        2 |    998.46 |     61.59 |
| 2018-05       |        2 |    322.37 |     36.61 |
| 2018-06       |       11 |  6,192.40 |  1,585.88 |
| 2018-07       |        5 |  4,624.67 |  1,103.34 |
| 2018-08       |        3 |  2,450.38 |    602.64 |
| 2018-09       |        5 |  1,229.32 |    303.93 |
| 2018-10       |        3 |  1,221.86 |    -32.36 |
| 2018-11       |        9 |  3,396.62 |    760.91 |
| 2018-12       |        3 |    569.46 |     48.45 |

## Q3. Top 10 customers by revenue
*Which customers contribute the most revenue?*

```sql
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
```

**Result:**

| customer_id   | customer_name   | segment     | customer_tier   |   orders |   total_revenue |   total_profit |
|:--------------|:----------------|:------------|:----------------|---------:|----------------:|---------------:|
| NP-18700      | Nora Preis      | Consumer    | Gold            |        1 |        4,630.51 |         242.99 |
| JK-15640      | Jim Kriz        | Home Office | Gold            |        3 |        4,177.38 |         988.67 |
| SR-20740      | Steven Roelle   | Home Office | Gold            |        2 |        3,567.42 |       1,669.38 |
| LC-16885      | Lena Creighton  | Consumer    | Gold            |        3 |        3,457.64 |       1,275.96 |
| GT-14710      | Greg Tran       | Consumer    | Gold            |        1 |        2,670.19 |         974.31 |
| LF-17185      | Luke Foster     | Consumer    | Gold            |        1 |        2,656.72 |      -3,791.16 |
| PW-19240      | Pierre Wener    | Consumer    | Gold            |        1 |        2,541.98 |       1,270.99 |
| HW-14935      | Helen Wasserman | Corporate   | Gold            |        1 |        2,340.06 |         595.74 |
| CC-12610      | Corey Catlett   | Corporate   | Gold            |        1 |        1,812.01 |         481.44 |
| KT-16480      | Kean Thornton   | Consumer    | Gold            |        1 |        1,799.97 |         240.00 |

## Q4. Sales and profitability by region (with regional manager)
*Which region sells the most, and which is the most profitable?*

```sql
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
```

**Result:**

| region_name   | manager_name      |   orders |   total_sales |   total_profit |   profit_margin_pct |
|:--------------|:------------------|---------:|--------------:|---------------:|--------------------:|
| West          | Anna Andreadi     |       53 |     28,159.75 |       5,270.76 |               18.72 |
| East          | Chuck Magee       |       38 |     25,471.02 |       6,409.04 |               25.16 |
| Central       | Kelly Williams    |       40 |     12,752.24 |      -4,205.83 |              -32.98 |
| South         | Cassandra Brandow |       24 |      8,559.95 |       2,355.98 |               27.52 |

## Q5. Average order value by customer segment
*How much is an average order worth in each customer segment?*

```sql
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
```

**Result:**

| segment     |   orders |   avg_order_value |   largest_order |
|:------------|---------:|------------------:|----------------:|
| Home Office |       25 |            578.37 |        4,150.97 |
| Corporate   |       33 |            577.52 |        2,340.06 |
| Consumer    |       97 |            427.07 |        4,630.51 |

## Q6. Products with sales above the average product
*Which products sell better than the average product?*

```sql
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
```

**Result:**

| product_id      | product_name                                                                | category        |   total_sales |
|:----------------|:----------------------------------------------------------------------------|:----------------|--------------:|
| OFF-BI-10003527 | Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind | Office Supplies |      5,592.36 |
| FUR-TA-10003473 | Bretford Rectangular Conference Table Tops                                  | Furniture       |      3,610.85 |
| TEC-MA-10003673 | Hewlett-Packard Desktjet 6988DT Refurbished Printer                         | Technology      |      3,404.50 |
| TEC-MA-10001148 | Swingline SM12-08 MicroCut Jam Free Shredder                                | Technology      |      2,875.19 |
| TEC-AC-10002049 | Plantronics Savi W720 Multi-Device Wireless Headset System                  | Technology      |      2,531.70 |
| OFF-BI-10004995 | GBC DocuBind P400 Electric Binding System                                   | Office Supplies |      2,177.58 |
| TEC-CO-10001449 | Hewlett Packard LaserJet 3310 Copier                                        | Technology      |      1,799.97 |
| TEC-CO-10001943 | Canon PC-428 Personal Copier                                                | Technology      |      1,599.92 |
| TEC-AC-10002253 | Imation Bio 8GB USB Flash Drive Imation Corp                                | Technology      |      1,496.16 |
| FUR-BO-10004357 | O'Sullivan Living Dimensions 3-Shelf Bookcases                              | Furniture       |      1,406.86 |
| TEC-MA-10004212 | Cisco SPA525G2 5-Line IP Phone                                              | Technology      |      1,379.92 |
| TEC-PH-10002555 | Nortel Meridian M5316 Digital phone                                         | Technology      |      1,294.75 |
| FUR-CH-10000309 | Global Comet Stacking Arm Chair                                             | Furniture       |      1,267.53 |
| FUR-TA-10003569 | Bretford CR8500 Series Meeting Room Furniture                               | Furniture       |      1,202.94 |
| OFF-AR-10002671 | Hunt BOSTON Model 1606 High-Volume Electric Pencil Sharpener, Beige         | Office Supplies |      1,113.02 |

## Q7. Sub-category profitability (profitable vs loss-making)
*Which sub-categories make or lose money? (only sub-categories with at least 3 order lines)*

```sql
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
```

**Result:**

| category        | sub_category   |   order_lines |   total_sales |   total_profit |   profit_margin_pct | status      |
|:----------------|:---------------|--------------:|--------------:|---------------:|--------------------:|:------------|
| Office Supplies | Binders        |            36 |     10,825.04 |        -528.18 |               -4.88 | Loss-making |
| Furniture       | Tables         |            12 |      9,223.04 |        -334.19 |               -3.62 | Loss-making |
| Office Supplies | Appliances     |            13 |      2,659.20 |         -40.79 |               -1.53 | Loss-making |
| Office Supplies | Fasteners      |             6 |         58.01 |          23.17 |               39.94 | High margin |
| Office Supplies | Supplies       |             5 |        101.64 |          24.31 |               23.92 | High margin |
| Office Supplies | Labels         |            14 |        222.51 |         100.08 |               44.98 | High margin |
| Office Supplies | Art            |            17 |      1,557.44 |         191.91 |               12.32 | Profitable  |
| Office Supplies | Envelopes      |            11 |        597.27 |         274.28 |               45.92 | High margin |
| Furniture       | Bookcases      |             6 |      3,825.31 |         290.32 |                7.59 | Profitable  |
| Office Supplies | Storage        |            22 |      4,115.33 |         411.01 |                9.99 | Profitable  |
| Furniture       | Chairs         |            14 |      6,288.43 |         493.01 |                7.84 | Profitable  |
| Furniture       | Furnishings    |            29 |      3,256.97 |         750.62 |               23.05 | High margin |
| Office Supplies | Paper          |            43 |      1,912.26 |         841.87 |               44.02 | High margin |
| Technology      | Copiers        |             3 |      4,359.87 |       1,303.95 |               29.91 | High margin |
| Technology      | Phones         |            33 |      8,948.35 |       1,479.67 |               16.54 | Profitable  |
| Technology      | Accessories    |            29 |      7,623.43 |       2,061.41 |               27.04 | High margin |
| Technology      | Machines       |             7 |      9,368.84 |       2,487.50 |               26.55 | High margin |

## Q8. Impact of discounts on profit
*Do heavier discounts hurt profitability?*

```sql
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
```

**Result:**

| discount_band      |   order_lines |   total_sales |   total_profit |   profit_margin_pct |
|:-------------------|--------------:|--------------:|---------------:|--------------------:|
| 1. No discount     |           153 |     34,783.53 |      11,383.33 |               32.73 |
| 2. Low (1-20%)     |           110 |     29,093.72 |       4,586.19 |               15.76 |
| 3. Medium (21-40%) |            15 |      7,325.44 |        -753.62 |              -10.29 |
| 4. High (over 40%) |            22 |      3,740.28 |      -5,385.96 |             -144.00 |

## Q9. Return rate by product category
*Which categories have the most returned orders?*

```sql
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
```

**Result:**

| category        |   orders |   returned_orders |   return_rate_pct |
|:----------------|---------:|------------------:|------------------:|
| Furniture       |       49 |                 7 |             14.29 |
| Technology      |       58 |                 6 |             10.34 |
| Office Supplies |      107 |                 9 |              8.41 |

## Q10. Shipping performance by ship mode
*How long does each shipping mode actually take, and how much revenue flows through it?*

```sql
SELECT o.ship_mode,
       COUNT(DISTINCT o.order_id)                          AS orders,
       ROUND(AVG(DATEDIFF(o.ship_date, o.order_date)), 2)  AS avg_days_to_ship,
       MAX(DATEDIFF(o.ship_date, o.order_date))            AS max_days_to_ship,
       ROUND(SUM(od.sales), 2)                             AS total_sales
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY o.ship_mode
ORDER BY avg_days_to_ship;
```

**Result:**

| ship_mode      |   orders |   avg_days_to_ship |   max_days_to_ship |   total_sales |
|:---------------|---------:|-------------------:|-------------------:|--------------:|
| Same Day       |        8 |               0.00 |                  0 |      6,588.59 |
| First Class    |       25 |               2.00 |                  3 |     15,561.66 |
| Second Class   |       26 |               2.91 |                  5 |     10,615.72 |
| Standard Class |       96 |               5.16 |                  7 |     42,177.00 |

## Q11. Top 3 products in each category (window function)
*What are the best-selling products inside each category?*

```sql
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
```

**Result:**

| category        |   sales_rank | product_name                                                                |   total_sales |
|:----------------|-------------:|:----------------------------------------------------------------------------|--------------:|
| Furniture       |            1 | Bretford Rectangular Conference Table Tops                                  |      3,610.85 |
| Furniture       |            2 | O'Sullivan Living Dimensions 3-Shelf Bookcases                              |      1,406.86 |
| Furniture       |            3 | Global Comet Stacking Arm Chair                                             |      1,267.53 |
| Office Supplies |            1 | Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind |      5,592.36 |
| Office Supplies |            2 | GBC DocuBind P400 Electric Binding System                                   |      2,177.58 |
| Office Supplies |            3 | Hunt BOSTON Model 1606 High-Volume Electric Pencil Sharpener, Beige         |      1,113.02 |
| Technology      |            1 | Hewlett-Packard Desktjet 6988DT Refurbished Printer                         |      3,404.50 |
| Technology      |            2 | Swingline SM12-08 MicroCut Jam Free Shredder                                |      2,875.19 |
| Technology      |            3 | Plantronics Savi W720 Multi-Device Wireless Headset System                  |      2,531.70 |
