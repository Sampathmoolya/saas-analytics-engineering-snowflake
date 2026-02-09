import pandas as pd
import random
from datetime import timedelta

from Subscriptions import generate_subscriptions
from Accounts import generate_accounts
accounts_df = generate_accounts()

subscriptions_df = generate_subscriptions(accounts_df)

def payment_generate(subscriptions_df):
    payments = []
    pay_id = 1

    plan_price = {
        "free_m": 0,
        "pro_m": 1000,
        "pro_y": 10000,
        "ent_m": 5000,
        "ent_y": 50000
    }

    for _, s in subscriptions_df.iterrows():
        plan_id = s["plan_id"]
        sub_id = s["subscription_id"]
        account_id = s["account_id"]         
        start = s["subscription_start_date"]
        end = s["subscription_end_date"]

        price = plan_price.get(plan_id, 0)

        # free plan → mostly no payments
        if plan_id.startswith("free") and random.random() < 0.95:
            continue

        # billing frequency
        freq_days = 30 if plan_id.endswith("_m") else 365

        # first payment after one cycle
        pay_date = start + timedelta(days=freq_days)

        # billing end
        last_date = end if end else start + timedelta(days=365)

        while pay_date <= last_date:
            status = "success" if random.random() > 0.15 else "failed"
            amount = price if status == "success" else 0

            # refund (rare)
            if status == "success" and random.random() < 0.05:
                amount = -price

            # system ingestion time (can lag payment_date)
            created_at = pay_date + timedelta(days=random.choice([0, 1, 2]))

            payments.append({
                "payment_id": f"P{pay_id}",
                "subscription_id": sub_id,
                "account_id": account_id,        
                "payment_date": pay_date,
                "amount": amount,
                "payment_status": status,
                "created_at": created_at         
            })

            pay_id += 1
            pay_date += timedelta(days=freq_days)

    return pd.DataFrame(payments)


payments_df = payment_generate(subscriptions_df)
payments_df.to_csv("raw_payments.csv", index=False)