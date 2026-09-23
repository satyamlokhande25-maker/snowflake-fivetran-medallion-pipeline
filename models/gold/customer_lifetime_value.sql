{{ config(
    materialized='table'
) }}

with customers as (
    select * from {{ ref('dim_customers') }}
),

transactions as (
    select * from {{ ref('fct_transactions') }}
),

customer_metrics as (
    select
        customer_id,
        count(transaction_id) as total_transactions,
        count(case when payment_status = 'Success' then 1 end) as successful_transactions,
        sum(case when payment_status = 'Success' then amount else 0 end) as total_spend_amount,
        min(transaction_date) as first_transaction_date,
        max(transaction_date) as latest_transaction_date
    from transactions
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.city,
        c.total_contracts,
        c.active_contracts,
        coalesce(cm.total_transactions, 0) as total_transactions,
        coalesce(cm.successful_transactions, 0) as successful_transactions,
        coalesce(cm.total_spend_amount, 0) as lifetime_revenue,
        cm.first_transaction_date,
        cm.latest_transaction_date
    from customers c
    left join customer_metrics cm
        on c.customer_id = cm.customer_id
)

select * from final