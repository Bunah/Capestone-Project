
import pandas as pd

def build_rfm_features(orders_df):
    rfm = orders_df.groupby('customer_id').agg({
        'order_date': lambda x: (pd.Timestamp.today() - x.max()).days,
        'order_id': 'count',
        'total_amount': 'sum'
    }).reset_index()
    rfm.columns = ['customer_id', 'recency', 'frequency', 'monetary']
    return rfm

def add_support_features(tickets_df):
    support = tickets_df.groupby('customer_id').agg({
        'ticket_id': 'count',
        'satisfaction_score': 'mean',
        'resolution_time_hours': 'mean'
    }).reset_index()
    support.columns = ['customer_id', 'ticket_count', 'avg_satisfaction', 'avg_resolution_time']
    return support

def merge_features(rfm, support):
    return pd.merge(rfm, support, on='customer_id', how='left')
