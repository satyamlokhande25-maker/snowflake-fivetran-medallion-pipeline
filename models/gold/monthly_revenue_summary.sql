{{ config(
    materialized='table'
) }}

with fct_transactions as (
    select * from {{ ref('fct_transactions') }}
),

monthly_aggregates as (
    select
        date_trunc('month', transaction_date) as transaction_month,
        coalesce(contract_type, 'Unassigned') as contract_type,
        payment_method,
        count(transaction_id) as total_transactions,
        count(case when payment_status = 'Success' then 1 end) as successful_transactions,
        count(case when payment_status = 'Failed' then 1 end) as failed_transactions,
        sum(case when payment_status = 'Success' then amount else 0 end) as total_successful_revenue,
        sum(case when payment_status = 'Failed' then amount else 0 end) as total_failed_revenue
    from fct_transactions
    group by 1, 2, 3
)

select * from monthly_aggregates