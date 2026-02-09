-- plan dimension table
SELECT* FROM saas.saas_data.raw_plans

CREATE OR REPLACE TABLE saas.saas_data.dim_plans AS
SELECT 
    plan_id,
    plan_name,
    price,
    billing_cycle,
    is_active
FROM saas.saas_data.raw_plans

-- dimension account table
SELECT * FROM SAAS.SAAS_DATA.RAW_ACCOUNT

CREATE OR REPLACE TABLE saas.saas_data.dim_accounts AS
SELECT
account_id,
account_type,
TO_DATE(created_at) as created_date,
status
FROM saas.saas_data.raw_account;


-- dim date table

CREATE OR REPLACE TABLE saas.saas_data.dim_date AS
WITH CTE AS (
    SELECT 
        MIN(d) AS start_date,
        CURRENT_DATE() AS end_date
    FROM (
        SELECT MIN(subscription_start_date) AS d FROM saas.saas_data.fact_subscription
        UNION ALL
        SELECT MIN(payment_date) FROM saas.saas_data.fact_payments
        UNION ALL
        SELECT MIN(event_date) FROM saas.saas_data.fact_usage
    )
),
CTE2 AS (
    SELECT 
        DATEADD(day, SEQ4(), start_date) AS date,
        end_date
    FROM CTE,
         TABLE(GENERATOR(ROWCOUNT => 10000))
)
SELECT
    date,
    YEAR(date) AS year,
    MONTH(date) AS month,
    TO_VARCHAR(date, 'Mon') AS month_name, 
    DATE_TRUNC('month', date) AS month_start, // provides dates--> first month date
    LAST_DAY(date) AS month_end,
    WEEK(date) AS week,
    DAYNAME(date) AS day_name
FROM CTE2
WHERE date <= end_date; // end_date is current_date (8/2/26)

SELECT * FROM saas.saas_data.dim_date;