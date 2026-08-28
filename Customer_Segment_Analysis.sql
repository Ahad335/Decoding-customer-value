-- PROJECT:  Decoding Customer Value — A SQL-Driven Retention Strategy
-- BY: Sanchita Gupta, Harsh Gupta

-- Load engineered customer dataset (customer_features_enriched.csv) into this table.

CREATE DATABASE IF NOT EXISTS d2c_fashion;
USE d2c_fashion;

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id              INT           PRIMARY KEY,
    age                      INT,
    gender                   VARCHAR(10),
    item_purchased           VARCHAR(50),
    category                 VARCHAR(30),
    purchase_amount_usd      INT,
    location                 VARCHAR(50),
    size                     VARCHAR(5),
    color                    VARCHAR(30),
    season                   VARCHAR(20),
    review_rating            DECIMAL(3,2),
    subscription_status      VARCHAR(5),
    shipping_type            VARCHAR(30),
    discount_applied         VARCHAR(5),
    promo_code_used          VARCHAR(5),
    previous_purchases       INT,
    payment_method           VARCHAR(20),
    frequency_of_purchases   VARCHAR(30),
    purchase_frequency_score INT,
    promo_dependent          TINYINT,
    high_satisfaction        TINYINT,
    customer_value_score     DECIMAL(6,4),
    value_tier               VARCHAR(10),
    loyalty_score_v1         DECIMAL(6,4),
    loyalty_score_v2         DECIMAL(6,4),
    loyalty_score            DECIMAL(6,4),
    is_loyal                 TINYINT
);

-- After creating the table, load data via:
-- MySQL Workbench > Right-click table > Table Data Import Wizard > select customer_features_enriched.csv

SELECT 
    COUNT(*)                             AS total_customers,
    COUNT(DISTINCT value_tier)           AS distinct_tiers,
    SUM(promo_dependent)                 AS promo_dependent_count,
    ROUND(AVG(customer_value_score), 4)  AS avg_value_score,
    ROUND(AVG(review_rating), 2)         AS avg_rating,
    MIN(previous_purchases)              AS min_prev_purchases,
    MAX(previous_purchases)              AS max_prev_purchases
FROM customers;

-- QUESTION 1 — Loyal vs Discount-Driven Customers

-- Q1a: Loyal vs. Promo-Dependent breakdown with behavioural profile
SELECT
    CASE 
        WHEN is_loyal = 1                        THEN 'Genuinely Loyal'
        WHEN promo_dependent = 1 AND is_loyal = 0 THEN 'Promo Hunter'
        ELSE 'Passive / Neutral'
    END                                          AS customer_type,
    COUNT(*)                                     AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)
                                                 AS pct_of_base,
    ROUND(AVG(purchase_amount_usd), 2)           AS avg_spend,
    ROUND(AVG(previous_purchases), 1)            AS avg_prev_purchases,
    ROUND(AVG(review_rating), 2)                 AS avg_rating,
    ROUND(AVG(purchase_frequency_score), 1)      AS avg_annual_freq
FROM customers
GROUP BY customer_type
ORDER BY customer_count DESC;


-- Q1b: Loyal vs. Promo-Hunter Segment distribution across value tiers

SELECT
    value_tier,
    SUM(is_loyal)                                                 AS loyal_count,
    SUM(promo_dependent)                                          AS promo_count,
    COUNT(*) - SUM(is_loyal) - SUM(promo_dependent)              AS neutral_count,
    COUNT(*)                                                      AS total,
    ROUND(SUM(is_loyal)       * 100.0 / COUNT(*), 1)             AS loyal_pct,
    ROUND(SUM(promo_dependent)* 100.0 / COUNT(*), 1)             AS promo_pct
FROM customers
GROUP BY value_tier
ORDER BY FIELD(value_tier, 'Low', 'Mid', 'High', 'Premium');


-- Q1c: Loyal vs Promo-Hunter profile comparison
SELECT
    'Loyal'                                     AS segment,
    ROUND(AVG(age), 1)                          AS avg_age,
    ROUND(AVG(purchase_amount_usd), 2)          AS avg_spend,
    ROUND(AVG(previous_purchases), 1)           AS avg_prev_purchases,
    ROUND(AVG(review_rating), 2)                AS avg_rating,
    ROUND(AVG(purchase_frequency_score), 1)     AS avg_annual_freq,
    ROUND(AVG(customer_value_score), 4)         AS avg_value_score
FROM customers WHERE is_loyal = 1
UNION ALL
SELECT
    'Promo Hunter',
    ROUND(AVG(age), 1),
    ROUND(AVG(purchase_amount_usd), 2),
    ROUND(AVG(previous_purchases), 1),
    ROUND(AVG(review_rating), 2),
    ROUND(AVG(purchase_frequency_score), 1),
    ROUND(AVG(customer_value_score), 4)
FROM customers WHERE promo_dependent = 1 AND is_loyal = 0;

-- QUESTION 2 — What behavioral patterns are drivers of Customer Value?

-- Q2a: Average value metrics by tier 
SELECT
    value_tier,
    COUNT(*)                                     AS count,
    ROUND(AVG(customer_value_score), 4)          AS avg_value_score,
    ROUND(AVG(previous_purchases), 1)            AS avg_prev_purchases,
    ROUND(AVG(purchase_frequency_score), 1)      AS avg_freq_score,
    ROUND(AVG(purchase_amount_usd), 2)           AS avg_spend,
    ROUND(AVG(review_rating), 2)                 AS avg_rating,
    ROUND(SUM(high_satisfaction) * 100.0 / COUNT(*), 1) AS satisfaction_rate_pct,
    ROUND(SUM(promo_dependent) * 100.0 / COUNT(*), 1)   AS promo_rate_pct
FROM customers
GROUP BY value_tier
ORDER BY FIELD(value_tier, 'Low', 'Mid', 'High', 'Premium');


-- Q2b: Payment preferences by tier
--      Tests hypothesis: Premium customers use credit/digital wallets more
SELECT
    value_tier,
    payment_method,
    COUNT(*)                                                AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY value_tier), 1) AS pct_in_tier
FROM customers
GROUP BY value_tier, payment_method
ORDER BY FIELD(value_tier, 'Low', 'Mid', 'High', 'Premium'), count DESC;


-- Q2c: Subscription and loyalty relationship
SELECT
    subscription_status,
    is_loyal,
    COUNT(*)                                     AS count,
    ROUND(AVG(customer_value_score), 4)          AS avg_value,
    ROUND(AVG(previous_purchases), 1)            AS avg_prev_purchases
FROM customers
GROUP BY subscription_status, is_loyal
ORDER BY subscription_status, is_loyal DESC;


-- Q2d: Frequency of purchase cross-tab with value tier
SELECT
    frequency_of_purchases,
    value_tier,
    COUNT(*)                                     AS count,
    ROUND(AVG(customer_value_score), 4)          AS avg_value_score
FROM customers
GROUP BY frequency_of_purchases, value_tier
ORDER BY FIELD(value_tier, 'Low', 'Mid', 'High', 'Premium'), count DESC;


-- QUESTION 3 —  Geographic Growth Opportunities
--              (High spend + low promo dependency = organic demand signal)

-- Q3a: organic vs. discount-driven by state
SELECT
    location                                         AS state,
    COUNT(*)                                         AS total_customers,
    ROUND(AVG(purchase_amount_usd), 2)               AS avg_spend,
    ROUND(SUM(promo_dependent) * 100.0 / COUNT(*), 1) AS promo_pct,
    ROUND(AVG(customer_value_score), 4)              AS avg_value_score,
    ROUND(AVG(review_rating), 2)                     AS avg_rating,
    -- Opportunity Score = High spend + Low promo dependence = best organic territory
    ROUND(AVG(purchase_amount_usd) * (1 - SUM(promo_dependent)*1.0/COUNT(*)), 2)
                                                     AS organic_opportunity_score
FROM customers
GROUP BY location
ORDER BY organic_opportunity_score DESC
LIMIT 20;


-- Q3b: Top 10 underleveraged markets 

--      These are states where the brand has GOOD organic customers but hasn't 
--      actively targeted them — prime markets for brand-pull expansion.

WITH geo_stats AS (
    SELECT
        location,
        COUNT(*)                                             AS customer_count,
        ROUND(AVG(purchase_amount_usd), 2)                  AS avg_spend,
        ROUND(SUM(promo_dependent) * 100.0 / COUNT(*), 1)   AS promo_pct,
        ROUND(AVG(customer_value_score), 4)                  AS avg_value
    FROM customers
    GROUP BY location
),
overall AS (
    SELECT 
        AVG(customer_count)  AS avg_count,
        AVG(avg_spend)       AS avg_spend_all,
        AVG(promo_pct)       AS avg_promo
    FROM geo_stats
)
SELECT
    g.location,
    g.customer_count,
    g.avg_spend,
    g.promo_pct,
    g.avg_value,
    CASE
        WHEN g.avg_spend > o.avg_spend_all AND g.promo_pct < o.avg_promo AND g.customer_count < o.avg_count
            THEN 'UNDERLEVERED — High Potential'
        WHEN g.avg_spend > o.avg_spend_all AND g.promo_pct < o.avg_promo
            THEN 'Strong Organic Market'
        WHEN g.promo_pct > o.avg_promo + 10
            THEN 'Discount-Driven — Risky'
        ELSE 'Baseline'
    END                                                       AS territory_flag
FROM geo_stats g, overall o
ORDER BY g.avg_spend DESC, g.promo_pct ASC;

-- QUESTION 4 — Promotion Strategy Assessment
-- (Which segments show the strongest repeat purchase behavior WITH discounts,
--  and which ones buy without them — indicating real brand pull?)

-- Q4a: Revenue-at-risk if discounts removed — by value tier
SELECT
    value_tier,
    COUNT(*)                                                AS total_customers,
    SUM(CASE WHEN promo_dependent = 1 THEN 1 ELSE 0 END)   AS promo_dependent_count,
    ROUND(SUM(CASE WHEN promo_dependent = 1 THEN purchase_amount_usd ELSE 0 END), 2)
                                                            AS revenue_at_risk_usd,
    ROUND(SUM(purchase_amount_usd), 2)                      AS total_segment_revenue,
    ROUND(
        SUM(CASE WHEN promo_dependent=1 THEN purchase_amount_usd ELSE 0 END) * 100.0 /
        SUM(purchase_amount_usd), 1
    )                                                       AS promo_revenue_pct
FROM customers
GROUP BY value_tier
ORDER BY FIELD(value_tier, 'Low', 'Mid', 'High', 'Premium');


-- Q4b: Promo usage by season

SELECT
    season,
    COUNT(*)                                               AS total_orders,
    SUM(promo_dependent)                                   AS promo_orders,
    ROUND(SUM(promo_dependent) * 100.0 / COUNT(*), 1)     AS promo_rate_pct,
    ROUND(AVG(purchase_amount_usd), 2)                     AS avg_spend,
    ROUND(AVG(purchase_amount_usd) 
        FILTER (WHERE promo_dependent = 0), 2)             AS avg_spend_no_promo,
    ROUND(AVG(purchase_amount_usd)
        FILTER (WHERE promo_dependent = 1), 2)             AS avg_spend_with_promo
FROM customers
GROUP BY season
ORDER BY promo_rate_pct DESC;


-- Q4c: Category x Promo dependency — which categories are training bargain hunters?
SELECT
    category,
    COUNT(*)                                               AS total,
    SUM(promo_dependent)                                   AS promo_users,
    ROUND(SUM(promo_dependent) * 100.0 / COUNT(*), 1)     AS promo_rate_pct,
    ROUND(AVG(previous_purchases), 1)                      AS avg_prev_purchases,
    ROUND(AVG(customer_value_score), 4)                    AS avg_value_score
FROM customers
GROUP BY category
ORDER BY promo_rate_pct DESC;


-- QUESTION 5 — Ideal Customer Profile

-- Q5: Composite ideal customer profile — Premium + Loyal segment deep dive
SELECT
    'IDEAL CUSTOMER PROFILE'                            AS segment_label,
    ROUND(AVG(age), 1)                                  AS avg_age,
    -- Gender split
    ROUND(SUM(CASE WHEN gender='Male' THEN 1 ELSE 0 END)*100.0/COUNT(*), 1) AS male_pct,
    ROUND(SUM(CASE WHEN gender='Female' THEN 1 ELSE 0 END)*100.0/COUNT(*), 1) AS female_pct,
    ROUND(AVG(purchase_amount_usd), 2)                  AS avg_spend,
    ROUND(AVG(previous_purchases), 1)                   AS avg_prev_purchases,
    ROUND(AVG(review_rating), 2)                        AS avg_rating,
    ROUND(AVG(purchase_frequency_score), 1)             AS avg_annual_freq,
    ROUND(AVG(customer_value_score), 4)                 AS avg_value_score, 
    (SELECT payment_method FROM customers 
     WHERE value_tier='Premium' AND is_loyal=1 
     GROUP BY payment_method ORDER BY COUNT(*) DESC LIMIT 1) AS top_payment_method,
    (SELECT season FROM customers 
     WHERE value_tier='Premium' AND is_loyal=1 
     GROUP BY season ORDER BY COUNT(*) DESC LIMIT 1)          AS top_season,
    (SELECT category FROM customers 
     WHERE value_tier='Premium' AND is_loyal=1 
     GROUP BY category ORDER BY COUNT(*) DESC LIMIT 1)        AS top_category,
    (SELECT frequency_of_purchases FROM customers 
     WHERE value_tier='Premium' AND is_loyal=1 
     GROUP BY frequency_of_purchases ORDER BY COUNT(*) DESC LIMIT 1) AS top_frequency
FROM customers
WHERE value_tier = 'Premium' AND is_loyal = 1;


-- Q5b: Premium loyal segment — location concentration
SELECT
    location,
    COUNT(*)                                                AS premium_loyal_count,
    ROUND(AVG(purchase_amount_usd), 2)                      AS avg_spend,
    ROUND(AVG(review_rating), 2)                            AS avg_rating
FROM customers
WHERE value_tier = 'Premium' AND is_loyal = 1
GROUP BY location
ORDER BY premium_loyal_count DESC
LIMIT 15;


-- Q5c: Customer Pyramid — revenue distribution visualization query
SELECT
    value_tier,
    COUNT(*)                                              AS customers,
    ROUND(SUM(purchase_amount_usd), 2)                    AS total_revenue,
    ROUND(SUM(purchase_amount_usd) * 100.0 / 
          (SELECT SUM(purchase_amount_usd) FROM customers), 1)
                                                          AS revenue_share_pct,
    ROUND(AVG(purchase_amount_usd), 2)                    AS avg_revenue_per_customer,
    SUM(is_loyal)                                         AS loyal_customers,
    SUM(promo_dependent)                                  AS promo_customers
FROM customers
GROUP BY value_tier
ORDER BY FIELD(value_tier, 'Premium', 'High', 'Mid', 'Low');

-- Entry vs. Retention Categories
-- Which categories appear among low-purchase customers vs. high-purchase ones?

SELECT
    category,
    ROUND(AVG(previous_purchases), 2)                     AS avg_prev_purchases,
    COUNT(*)                                               AS total,
    SUM(CASE WHEN previous_purchases <= 10 THEN 1 ELSE 0 END) AS low_history_customers,
    SUM(CASE WHEN previous_purchases >= 35 THEN 1 ELSE 0 END) AS high_history_customers,
    ROUND(SUM(CASE WHEN previous_purchases<=10 THEN 1 ELSE 0 END)*100.0/COUNT(*), 1)
                                                           AS entry_customer_pct,
    ROUND(SUM(CASE WHEN previous_purchases>=35 THEN 1 ELSE 0 END)*100.0/COUNT(*), 1)
                                                           AS retention_customer_pct
FROM customers
GROUP BY category
ORDER BY avg_prev_purchases DESC;
