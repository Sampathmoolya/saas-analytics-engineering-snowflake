import pandas as pd
import random
from datetime import timedelta
from faker import Faker
from Accounts import generate_accounts
from Subscriptions import generate_subscriptions
from Users import generate_users

fake  = Faker()
accounts_df = generate_accounts()
subscriptions_df =  generate_subscriptions(accounts_df)
users_df = generate_users(accounts_df)

def events_generate(accounts_df, subscriptions_df, users_df):
    events = []
    event_id = 1

    event_types = ["login", "feature_call", "api_call", "export"]

    for _, sub in subscriptions_df.iterrows():
        account_id = sub["account_id"]
        plan_id = sub["plan_id"]
        start = sub["subscription_start_date"]
        end = sub["subscription_end_date"]

        account_users = users_df[users_df["account_id"] == account_id]

        # usage intensity by plan
        if plan_id.startswith("free"):
            max_events_per_user = 10
        elif plan_id.startswith("pro"):
            max_events_per_user = 40
        else:
            max_events_per_user = 80

        # activity window
        last_date = end if end else fake.date_between(start_date="-30d", end_date="today")

        for _, user in account_users.iterrows():

            # some users never use product
            if random.random() < 0.2:
                continue

            num_events = random.randint(1, max_events_per_user)

            for _ in range(num_events):
                event_time = fake.date_time_between(start_date=start, end_date=last_date)

                # ingestion/system time (can be late)
                created_at = fake.date_time_between(
                    start_date=event_time,
                    end_date=event_time + timedelta(days=2)
                )

                events.append({
                    "event_id": f"E{event_id}",
                    "user_id": user["user_id"],
                    "account_id": account_id,
                    "event_type": random.choice(event_types),
                    "event_timestamp": event_time,
                    "created_at": created_at
                })

                event_id += 1

    # bad data: events after churn (small %)
    for _ in range(int(len(events) * 0.03)):
        event_time = fake.date_time_between(start_date="+1d", end_date="+15d")
        created_at = fake.date_time_between(start_date=event_time, end_date=event_time + timedelta(days=2))

        events.append({
            "event_id": f"E{event_id}",
            "user_id": random.choice(users_df["user_id"].tolist()),
            "account_id": random.choice(accounts_df["account_id"].tolist()),
            "event_type": random.choice(event_types),
            "event_timestamp": event_time,
            "created_at": created_at
        })
        event_id += 1

    return pd.DataFrame(events)

    
events_df = events_generate(accounts_df, subscriptions_df, users_df)
events_df['event_timestamp'] =  events_df['event_timestamp'].astype(str)
events_df.to_csv("raw_events.csv", index=False)