CREATE DATABASE Saas;

CREATE SCHEMA Saas.Saas_data;

CREATE TABLE Saas.Saas_data.raw_accounts(
  account_id STRING,
  account_type STRING,
  created_at STRING,   
  status STRING
);

CREATE TABLE Saas.Saas_data.raw_users(
user_id STRING,
account_id STRING,
email STRING,
signup_date DATE,
last_login_at STRING
);

CREATE TABLE Saas.Saas_data.raw_plans(
plan_id STRING,
plan_name STRING,  --Free, pro or enterprise
price NUMBER(10,2), -- 0 or Free
billing_cycle STRING, -- monthly/ yearly
is_active BOOLEAN
);

CREATE TABLE Saas.Saas_data.raw_subscriptions(
subscription_id STRING,
account_id STRING,
plan_id STRING,
subscription_start_date DATE,
subscription_end_date DATE, --nullable
subscription_status STRING, --trial/ active/ cancelled
created_at STRING
);

CREATE TABLE Saas.Saas_data.raw_payments (
  payment_id STRING,
  account_id STRING,
  subscription_id STRING,
  amount NUMBER(10,2),
  payment_date DATE,
  payment_status STRING, -- success / failed / refunded
  created_at STRING
);

CREATE TABLE Saas.Saas_data.raw_events (
  event_id STRING,
  user_id STRING,
  account_id STRING,
  event_type STRING,  -- login, feature_used, export, etc.
  event_timestamp TIMESTAMP,
  created_at TIMESTAMP
);
