
import pandas as pd

def clean_customers(df):
    df = df.drop_duplicates()
    df['state'] = df['state'].str.upper()
    df['membership_tier'] = df['membership_tier'].str.title()
    return df

def clean_orders(df):
    df = df.dropna(subset=['order_id'])
    df['order_date'] = pd.to_datetime(df['order_date'], errors='coerce')
    df = df[df['order_date'].notnull()]
    return df

def clean_products(df):
    df = df.drop_duplicates(subset=['product_id'])
    df['is_active'] = df['is_active'].map({'Yes': True, 'No': False})
    return df

def clean_support_tickets(df):
    df = df.dropna(subset=['ticket_id'])
    df['ticket_date'] = pd.to_datetime(df['ticket_date'], errors='coerce')
    return df
