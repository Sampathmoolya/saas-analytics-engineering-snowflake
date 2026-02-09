-- RAW SUBSCRIPTIONS TABLE --> staging
SELECT * from SAAS.SAAS_DATA.RAW_SUBSCRIPTIONS
CREATE OR REPLACE TABLE SAAS.SAAS_DATA.stg_subscriptions AS
SELECT
subscription_id,
account_id,
plan_id,
subscription_start_date,
subscription_end_date,
CASE WHEN 
    subscription_end_date IS NULL THEN 'active'
    ELSE
    'canceled'
END AS subscription_status
FROM SAAS.SAAS_DATA.RAW_SUBSCRIPTIONS;

SELECT * FROM SAAS.SAAS_DATA.STG_SUBSCRIPTIONS;

-- RAW PAYMENT TABLE --> STAGING 
SELECT * FROM SAAS.SAAS_DATA.RAW_PAYMENTS;

-- ONLY SUCCESSFUL PAYMENTS TABLE
CREATE OR REPLACE TABLE SAAS.SAAS_DATA.stg_payments AS
SELECT
    payment_id,
    subscription_id,
    account_id,
    payment_date,
    amount
FROM SAAS.SAAS_DATA.raw_payments
WHERE payment_status = 'success';

SELECT
COUNT(*) AS ROW_COUNTS,
SUM(amount) FROM SAAS.SAAS_DATA.STG_PAYMENTS;

-- PAYMENTS WHICH INCLUDES BOTH FAILURES AND SUCCESS-
CREATE OR REPLACE TABLE SAAS.SAAS_DATA.stg_payment_attempts AS
SELECT 
    payment_id,
    account_id,
    subscription_id,
    payment_status
FROM SAAS.SAAS_DATA.RAW_PAYMENTS;

SELECT
COUNT(*) AS COUNT_ROWS
from SAAS.SAAS_DATA.stg_payment_attempts;

--RAW EVENT --> STAGING
SELECT * FROM SAAS.SAAS_DATA.RAW_EVENTS;

-- Usage tied to active subscriptions OR usage before subscription end
CREATE OR REPLACE TABLE SAAS.SAAS_DATA.stg_events AS
SELECT
    e.event_id,
    e.user_id,
    e.account_id,
    e.event_type,
    e.event_timestamp
from SAAS.SAAS_DATA.RAW_EVENTS e JOIN SAAS.SAAS_DATA.stg_subscriptions s
ON e.account_id = s.account_id
AND e.event_timestamp >= s.subscription_start_date  // we dont need after churning
AND (
    s.subscription_end_date IS NULL  //active subscription is not null !
    OR e.event_timestamp <= s.subscription_end_date // event should before subscription end date
)

SELECT COUNT(*) as Count_rows
FROM saas.saas_data.stg_events;

SELECT COUNT(*) AS COUNT_ROWS
FROM SAAS.SAAS_DATA.RAW_EVENTS


CREATE OR REPLACE TABLE SAAS.SAAS_DATA.stg_events AS
SELECT
    e.event_id,
    e.user_id,
    e.account_id,
    e.event_type,
    e.event_timestamp,
    s.subscription_id
FROM SAAS.SAAS_DATA.raw_events e
JOIN SAAS.SAAS_DATA.stg_subscriptions s
  ON e.account_id = s.account_id
 AND e.event_timestamp >= s.subscription_start_date
 AND (
        s.subscription_end_date IS NULL
        OR e.event_timestamp <= s.subscription_end_date
     )
QUALIFY
    ROW_NUMBER() OVER (
        PARTITION BY e.event_id
        ORDER BY s.subscription_start_date DESC
    ) = 1;
