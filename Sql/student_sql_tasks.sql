-- Q1 (Basic SELECT/WHERE/ORDER BY)
-- List the 20 most recent orders with status 'Completed', showing order_id,
-- customer_id, order_date and total_amount, most recent first.
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE order_status = 'Completed'
ORDER BY order_date DESC
LIMIT 20;

--Q2 (Aggregation/GROUP BY)
--For each membership_tier, calculate the number of customers, total revenue
-- generated (completed orders only), and average order value.
SELECT 
    c.membership_tier,
    COUNT(DISTINCT c.customer_id) AS num_customers,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.membership_tier
ORDER BY c.membership_tier;


--Q3 (JOIN)
-- List the top 15 products by total revenue (quantity * unit_price_at_purchase),
-- including product_name, category, and brand.
SELECT 
    p.product_name,
    p.category,
    p.brand,
    SUM(oi.quantity * oi.unit_price_at_purchase) AS total_revenue
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category, p.brand
ORDER BY total_revenue DESC
LIMIT 15;

-- Q4 (JOIN across 3+ tables)
-- For every customer in the 'Platinum' tier, show their total number of
-- orders, total spend, and total number of support tickets raised.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spend,
    COUNT(DISTINCT s.ticket_id) AS total_tickets
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id 
    AND o.order_status = 'Completed'
LEFT JOIN support_tickets s 
    ON c.customer_id = s.customer_id
WHERE c.membership_tier = 'Platinum'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spend DESC;

-- Q5 (Subquery)
-- Find all customers whose total spend (completed orders) is above the
-- overall average total spend per customer.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS customer_total_spend
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(customer_spend)
    FROM (
        SELECT SUM(o2.total_amount) AS customer_spend
        FROM customers c2
        JOIN orders o2 
            ON c2.customer_id = o2.customer_id
        WHERE o2.order_status = 'Completed'
        GROUP BY c2.customer_id
    )
);

-- Q6 (Subquery / NOT IN or NOT EXISTS)
-- Find all customers who have never placed an order.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.membership_tier
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT DISTINCT o.customer_id
    FROM orders o
);


-- Q7 (CASE statement)
-- Categorize each order into a "value_band": 'Low' (<$50), 'Medium' ($50-$200),
-- 'High' (>$200). Report the count of orders and total revenue per band.
SELECT 
    CASE 
        WHEN o.total_amount < 50 THEN 'Low'
        WHEN o.total_amount BETWEEN 50 AND 200 THEN 'Medium'
        WHEN o.total_amount > 200 THEN 'High'
    END AS value_band,
    COUNT(*) AS order_count,
    SUM(o.total_amount) AS total_revenue
FROM orders o
WHERE o.order_status = 'Completed'
GROUP BY value_band
ORDER BY total_revenue DESC;

-- Q8 (Date logic / recency — this is your churn label!)
-- Using a snapshot date of '2026-07-01', label each customer as 'Churned'
-- (no completed order in the last 180 days, or never ordered) or 'Active'.
-- Report the count of customers in each label.
SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1
            FROM orders o
            WHERE o.customer_id = c.customer_id
              AND o.order_status = 'Completed'
              AND o.order_date >= DATE('2026-07-01', '-180 days')
        )
        THEN 'Churned'
        ELSE 'Active'
    END AS churn_label,
    COUNT(*) AS customer_count
FROM customers c
GROUP BY churn_label;

-- Q9 (Aggregation + HAVING)
-- Find product categories where average order item quantity exceeds 1.5.
SELECT 
    p.category,
    AVG(oi.quantity) AS avg_quantity
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
HAVING AVG(oi.quantity) > 1.5
ORDER BY avg_quantity DESC;

-- Q10 (Data modification)
-- Write an UPDATE statement that corrects any order_items rows where
-- quantity is negative (assume it should be the absolute value).
-- Write a DELETE statement that removes exact duplicate rows from
-- order_items (same order_id, product_id, quantity, unit_price_at_purchase
-- update abs
UPDATE order_items
SET quantity = ABS(quantity)
WHERE quantity < 0;

-- delete dublicate
DELETE FROM order_items
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM order_items
    GROUP BY order_id, product_id, quantity, unit_price_at_purchase
);

-- Q11 (Constraints / schema design question — answer in a comment, no SQL needed)
-- Explain what would go wrong if 'customer_id' in orders was NOT declared as
-- a foreign key referencing customers, given what you found in Q6 and the
-- orphaned customer_ids present in the raw orders data.
/*
what could go wrong
Orphaned orders → You could insert orders with customer_id values that don’t exist in the customers table. 
In Q6, we already saw customers who never placed an order; without the foreign key, you could also end up 
with orders pointing to customers who don’t exist at all.

Broken joins → Any analysis that joins orders to customers would produce incomplete or misleading results, 
because some orders would fail to match a valid customer record.

Churn analysis errors → Since churn labeling depends on linking customers to their orders, missing or 
invalid customer references would distort churn counts and predictions.

Data quality issues → Reports like “total spend per customer” or “orders per membership tier” would be 
inaccurate, because some orders wouldn’t belong to any real customer.
*/

-- Q12 (Performance)
-- The query in Q1 filters on order_status and sorts by order_date. Which
-- index(es) would help this query, and why? (Answer in a comment; you may
-- also run EXPLAIN QUERY PLAN in SQLite to support your answer.)
--Answer
/*
The query in Q1 filters on order_status and sorts by order_date.
To optimize this, two indexes would be helpful:
1. An index on (order_status, order_date):    - This composite index allows the database to quickly find all rows
     with order_status = 'Completed' and then efficiently sort them
     by order_date.

Without these indexes, SQLite would scan the entire orders table and
then sort results, which is slower on large datasets.
Running EXPLAIN QUERY PLAN would confirm whether the query uses the
index or falls back to a full table scan.
*/