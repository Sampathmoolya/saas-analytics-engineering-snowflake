# SaaS Analytics Engineering Pipeline (Snowflake)

## Overview

This project demonstrates an **analytics engineering workflow for a SaaS domain**, focused on **data modeling, warehouse design, and business-rule discovery** using **Snowflake SQL**.

The primary goal of this project is **not dashboarding or final business KPIs**, but to show how raw SaaS-style data can be transformed into **analytics-ready fact and dimension tables** with correct time logic, joins, and assumptions.

All transformations are implemented **directly in Snowflake**, without external transformation tools.

---

## Project Scope

### Included
- Synthetic SaaS data generation using Python
- Data ingestion into Snowflake
- RAW → STAGING → FACT / DIM modeling
- Exploratory Data Analysis (EDA)
- Business-rule validation and discovery

### Intentionally Excluded
- Executive dashboards
- Finalized SaaS KPIs (MRR, Revenue, Churn reporting)
- Power BI / visualization layer

These were excluded due to **data realism limitations**, which are documented below.

---

## Architecture

Python (Synthetic Data)  
↓  
Snowflake RAW Tables  
↓  
STAGING Tables (cleaning, filtering, corrections)  
↓  
FACT Tables (events, payments, subscriptions)  
↓  
DIMENSION Tables (plans, accounts, dates)

### Design Principles
- RAW tables are immutable
- All business logic lives in SQL
- Fact tables are event-based and time-aware
- Dimensions are descriptive and reusable

---

## Data Generation

Synthetic SaaS data was generated using Python to simulate:
- Accounts
- Users
- Plans
- Subscriptions
- Payments
- Usage events

The generator prioritizes **structural variety** over perfect business realism, allowing modeling and EDA layers to surface data quality and semantic issues.

---

## Exploratory Data Analysis (EDA)

EDA was performed after loading RAW data into Snowflake to validate assumptions and identify inconsistencies.

### Key Findings
- Subscription status and `end_date` inconsistencies
- No overlapping subscriptions per account (after validation)
- Churn is reversible (accounts can re-subscribe)
- Payments include failures and refunds
- Gross payments ≠ revenue
- Usage is bursty and does not show a strong pre-churn drop
- Events after subscription churn must be excluded
- Free plans contain successful payment records (data realism issue)

These findings directly influenced staging logic and fact table design.

---

## Data Modeling

### Staging Layer
Purpose:
- Clean raw data
- Enforce basic filters
- Resolve inconsistencies before analytics

Examples:
- Active vs canceled subscription logic
- Successful payments only (refunds retained as negative values)
- Event-to-subscription mapping using time windows
- Fan-out prevention using window functions

---

### Fact Tables

- **fact_subscriptions**
  - One row per subscription
  - `start_date`, `end_date`, `is_active`, `duration_days`

- **fact_payments**
  - One row per successful payment
  - Refunds represented as negative amounts
  - Plan resolved **at payment time** using date-range joins

- **fact_usage**
  - One row per usage event
  - Events after churn excluded

---

### Dimension Tables

- **dim_plans**
- **dim_accounts**
- **dim_date**

These provide descriptive attributes and support time-based analytics.

---

## Revenue Attribution Design

A key modeling decision was **plan attribution at payment time**, not current plan state.

Payments are joined to subscriptions using a time-aware condition:

payment_date BETWEEN subscription_start AND subscription_end

This avoids common SaaS reporting errors when customers upgrade or downgrade plans.

---

## Known Limitations

This project intentionally documents limitations instead of hiding them:

- Data is synthetic and does not fully enforce real SaaS billing constraints
- Monetization mechanics (add-ons, usage overages, invoice line items) are not modeled
- Free plans contain payment records due to flexible data generation
- Because of these constraints, **final business KPIs and dashboards were intentionally not built**

The project stops at the **analytics engineering layer** by design.

---

## What This Project Demonstrates

- Analytics engineering thinking
- Warehouse-first data modeling
- Time-aware joins and fact design
- EDA-driven modeling decisions
- Ability to identify when data cannot support business conclusions

---

## Tech Stack

- Snowflake – Data warehouse and SQL transformations
- Python – Synthetic data generation
- SQL – Analytics engineering and modeling

---

## Future Improvements (Out of Scope)

- Add billing line items and revenue types
- Enforce stricter business constraints during data generation
- Add dbt-style testing and documentation
- Build a separate business-metrics project using more realistic data

---

## Final Note

This repository is intentionally positioned as an **analytics engineering and data modeling case study**, not a polished SaaS metrics dashboard.
