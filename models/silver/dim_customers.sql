{{ config(
    materialized='table'
) }}

with customers as (
    select * from {{ ref('stg_customers') }}
),

contracts as (
    select * from {{ ref('stg_contracts') }}
),

customer_contracts as (
    select
        customer_id,
        count(contract_id) as total_contracts,
        count(case when contract_status = 'Active' then 1 end) as active_contracts
    from contracts
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.email,
        c.city,
        coalesce(cc.total_contracts, 0) as total_contracts,
        coalesce(cc.active_contracts, 0) as active_contracts,
        c.created_at,
        c.updated_at
    from customers c
    left join customer_contracts cc
        on c.customer_id = cc.customer_id
)

select * from final