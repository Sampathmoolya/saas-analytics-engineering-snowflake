-- active subscriptions till now 
SELECT COUNT(*) AS sub_count FROM saas.saas_data.fact_subscription s
WHERE s.is_active = true;


--monthly churn = how many subscriptions ended each month ?
SELECT 
    COUNT(*) AS sub_count,
    MONTH(d.date) as month,
    YEAR(d.date) as year
FROM saas.saas_data.fact_subscription s
JOIN saas.saas_data.dim_date d
ON s.subscription_end_date = d.date 
WHERE s.is_active = false
GROUP BY MONTH(d.date), YEAR(d.date)
ORDER BY sub_count DESC;


-- Monthly recuring revenue (MRR) = how much revenue per month
SELECT
    SUM(p.amount) AS total_amount,
    d.month, d.year
FROM saas.saas_data.fact_payments p
JOIN saas.saas_data.dim_date d
  ON p.payment_date BETWEEN d.month_start AND d.month_end
GROUP BY d.month, d.year
ORDER BY total_amount DESC;


-- Revenue by paid plans = Which plan makes the most money?
SELECT
    p.plan_name as plan_name,
    SUM(f.amount) as amount
FROM saas.saas_data.fact_subscription s
JOIN saas.saas_data.dim_plans p
    ON p.PLAN_ID = s.plan_id
JOIN saas.saas_data.fact_payments f
    ON f.subscription_id = s.subscription_id
GROUP by plan_name
ORDER by amount DESC


