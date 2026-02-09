import pandas as pd
from faker import Faker
import random 
from datetime import timedelta

from Accounts import generate_accounts
accounts_df = generate_accounts()

def generate_subscriptions(accounts_df):

    fake = Faker()
    subscriptions = []
    sub_id = 1

    plan_choices = ["free_m","pro_m", "pro_y", "ent_m", "ent_y"]

    for acc in accounts_df["account_id"]:

        num_subs = random.choice([1,1,2,2,3])
        last_end_date = None

        for i in range(num_subs):

            if i == 0:
                plan_id = random.choice(['free_m', 'pro_m'])
            else:
                plan_id = random.choice(plan_choices)

            if last_end_date:
                gap_days = random.choice([0,5,15,30])
                start_date = last_end_date + timedelta(days=gap_days)
            else:
                start_date = fake.date_between(start_date='-12M', end_date='-6M')

            duration_days = random.choice([30,60,90,180])

            churn_prob = 0.5 if plan_id.startswith("free") else 0.3
            is_active = random.random() > churn_prob

            if is_active:
                end_date = None
                status = "active"
            else:
                end_date = start_date + timedelta(days=duration_days)
                status = "canceled"

            if random.random() < 0.04:
                status = "active" if status == "canceled" else "canceled"

            subscriptions.append({
                "subscription_id": f"S{sub_id}",
                "account_id": acc,
                "plan_id": plan_id,
                "subscription_start_date": start_date,
                "subscription_end_date": end_date,
                "subscription_status": status,
                "created_at": start_date
            })

            sub_id += 1
            last_end_date = end_date or (start_date + timedelta(days=duration_days))

    return pd.DataFrame(subscriptions)

subscriptions_df = generate_subscriptions(accounts_df)
subscriptions_df.to_csv("raw_subscriptions.csv", index=False)