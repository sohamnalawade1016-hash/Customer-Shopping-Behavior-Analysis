-- Customer Behavior Analysis | MySQL 8.0+ (window functions need 8.0+)
-- Table: customer (one row per customer, 3,900 rows, no date column)
-- Note: results are descriptive comparisons, not causal claims.

--Q1. Total revenue and average spend by gender
-- (totals alone mislead: males are 2x the customers, so show avg and count too)
SELECT gender,
       COUNT(*) AS customers,
       SUM(purchase_amount) AS revenue,
       ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer
GROUP BY gender
ORDER BY revenue DESC;


--Q2. Customers who used a discount but spent MORE than the overall average
-- FIX: >= changed to > ("more than")
SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer)
ORDER BY purchase_amount DESC;


--Q3. Top 5 products by average review rating
-- FIX: added review count (ratings from tiny samples are unreliable) and a tie-breaker
SELECT item_purchased,
       ROUND(AVG(review_rating), 2) AS avg_product_rating,
       COUNT(*) AS num_orders
FROM customer
GROUP BY item_purchased
ORDER BY avg_product_rating DESC, num_orders DESC, item_purchased
LIMIT 5;


--Q4. Average purchase amount: Standard vs Express shipping
SELECT shipping_type,
       ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type
ORDER BY avg_purchase DESC;


--Q5. Do subscribers spend more? Average spend and total revenue by subscription status
-- FIX: ORDER BY was total_revenue ASC; now highest revenue first
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount), 2) AS avg_spend,
       ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;


--Q6. Top 5 products by % of purchases with a discount applied
-- FIX: added tie-breaker so the top 5 is deterministic
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC, item_purchased
LIMIT 5;


--Q7. Segment customers into New / Returning / Loyal by previous purchases
-- FIX: old rule (1 / 2-10 / 11+) put 79.9% of customers in "Loyal" and only 83 in "New",
-- which is a useless segmentation. previous_purchases ranges 1-50, so new cut-offs:
--   New = 1-10, Returning = 11-30, Loyal = 31+
WITH customer_type AS (
    SELECT customer_id,
           previous_purchases,
           CASE
               WHEN previous_purchases <= 10 THEN 'New'
               WHEN previous_purchases <= 30 THEN 'Returning'
               ELSE 'Loyal'
           END AS customer_segment
    FROM customer
)
SELECT customer_segment,
       COUNT(*) AS number_of_customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers
FROM customer_type
GROUP BY customer_segment
ORDER BY MIN(previous_purchases);


--Q8. Top 3 most purchased products within each category
-- FIX: ROW_NUMBER -> DENSE_RANK so tied products are not dropped arbitrarily
-- (can return more than 3 rows per category when there are ties)
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT category, item_rank, item_purchased, total_orders
FROM item_counts
WHERE item_rank <= 3
ORDER BY category, item_rank, item_purchased;


--Q9. Are repeat buyers (more than 5 previous purchases) more likely to subscribe?
-- FIX: old query only counted subscribers among repeat buyers, which cannot answer "likely".
-- Now compares the subscription RATE for repeat vs non-repeat buyers.
SELECT CASE WHEN previous_purchases > 5 THEN 'Repeat (>5)' ELSE 'Non-repeat (<=5)' END AS buyer_type,
       COUNT(*) AS customers,
       SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) AS subscribers,
       ROUND(100.0 * SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS subscription_rate_pct
FROM customer
GROUP BY buyer_type
ORDER BY buyer_type DESC;


--Q10. Revenue contribution of each age group (with % share)
-- age_group = age quartiles from pd.qcut, not fixed demographic bands
SELECT age_group,
       SUM(purchase_amount) AS total_revenue,
       ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 2) AS pct_of_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;
