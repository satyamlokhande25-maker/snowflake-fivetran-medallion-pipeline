{{ config(
    materialized='table'
) }}

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

contracts as (
    select * from {{ ref('stg_contracts') }}
),

final as (
    select
        t.transaction_id,
        t.customer_id,
        t.contract_id,
        c.contract_type,
        t.amount,
        t.payment_method,
        t.payment_status,
        t.transaction_date,
        date(t.transaction_date) as transaction_day,
        t.created_at
    from transactions t
    left join contracts c
        on t.contract_id = c.contract_id
)

select * from final