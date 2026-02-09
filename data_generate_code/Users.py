import pandas as pd
from faker import Faker
import random

from Accounts import generate_accounts

#  USERS

fake = Faker()
def generate_users(accounts_df):
    users = []
    user_id = 1

    for acc in accounts_df["account_id"]:
        for i in range(random.randint(1, 4)):
            users.append({
                "user_id" : {user_id},
                "account_id": acc,
                "email": fake.email(),
                "signup_date": fake.date_between(start_date= '-1y', end_date="today"),
                "last_login_at": fake.date_time_between(start_date= '-30d', end_date= 'now')
        })

            user_id = user_id+1

    users_df = pd.DataFrame(users)
    return users_df

accounts_df = generate_accounts() 
users_df = generate_users(accounts_df)

users_df['last_login_at'] = users_df['last_login_at'].astype(str) #getting error while uploading in snowflake- timestamp error
users_df.to_csv("raw_users.csv", index=False)

print(users_df["last_login_at"].dtypes)
print(users_df["signup_date"].dtypes)