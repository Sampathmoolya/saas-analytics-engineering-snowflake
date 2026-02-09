import pandas as pd
# plans-

plans = pd.DataFrame ([
# Free
{"plan_id": "free_m", "plan_name": "Free", "price": 0, "billing_cycle": "monthly", "is_active": True},

# Pro
{"plan_id": "pro_m", "plan_name": "Pro", "price": 999, "billing_cycle": "monthly", "is_active": True},  #monthly
{"plan_id": "pro_y", "plan_name": "Pro", "price": 9999, "billing_cycle": "yearly", "is_active": True}, #yearly

# Enterprise
{"plan_id": "ent_m", "plan_name": "Enterprise", "price": 4999, "billing_cycle": "monthly", "is_active": True},  #monthly

{"plan_id": "ent_y", "plan_name": "Enterprise", "price": 49999, "billing_cycle": "yearly", "is_active": True},  #yearly

]
)

plans.to_csv("raw_plans.csv", index=False)