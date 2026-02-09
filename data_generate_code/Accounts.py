import pandas as pd
from faker import Faker
import random 

fake = Faker()

# ACCOUNTS
def generate_accounts():
    accounts= []
    for i in range(1, 101):  #creating 100 account
        accounts.append({
            "account_id": f"A{i}",
            "account_type": random.choice(['individual', 'company']),
            "created_at": fake.date_time_between(start_date= '-1y', end_date= 'now'),
            "status": random.choice(['active', 'active', 'active', 'closed'])

        })

    accounts_df = pd.DataFrame(accounts)
    return accounts_df

accounts_df = generate_accounts()

accounts_df['created_at'] = accounts_df['created_at'].astype(str) #getting error while uploading in snowflake- timestamp error
accounts_df.to_csv('raw_accounts.csv', skiprows =1, index = False)
