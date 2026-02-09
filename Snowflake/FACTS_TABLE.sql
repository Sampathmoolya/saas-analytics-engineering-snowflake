-- fact_subscription table
select *from saas.saas_data.stg_subscriptions;
DESC TABLE saas.saas_data.stg_subscriptions;

CREATE OR REPLACE TABLE saas.saas_data.fact_subscription AS
SELECT 
    subscription_id,
    account_id,
    plan_id,
    subscription_start_date,
    subscription_end_date,
    (subscription_status = 'active') AS is_active,
    DATEDIFF(
        'day',
        subscription_start_date,
        COALESCE(subscription_end_date, CURRENT_DATE)
    ) AS duration_days
FROM saas.saas_data.stg_subscriptions;


-- fact_payment table
SELECT * FROM saas.saas_data.stg_payments
DESC TABLE saas.saas_data.stg_payments

CREATE OR REPLACE TABLE SAAS.SAAS_DATA.fact_payments AS
SELECT
p.payment_id,
s.account_id,
p.subscription_id,
s.plan_id ,            --CAPTURE PLAN AT PAYMENT TIME
p.payment_date,
p.amount
FROM saas.saas_data.stg_payments p
JOIN saas.saas_data.stg_subscriptions s
ON p.subscription_id = s.subscription_id
AND p.payment_date >= s.subscription_start_date  --payment date should lie inside sub.start and sub.end date!
AND(
    s.subscription_end_date IS NULL
    OR s.subscription_end_date <= p.payment_date
);


-- fact_event table
SELECT * FROM saas.saas_data.stg_events;
CREATE OR REPLACE TABLE saas.saas_data.fact_usage AS
SELECT
account_id,
user_id,
event_type,
TO_DATE(EVENT_TIMESTAMP) as event_date
FROM saas.saas_data.stg_events

SELECT * FROM SAAS.SAAS_DATA.FACT_USAGE
