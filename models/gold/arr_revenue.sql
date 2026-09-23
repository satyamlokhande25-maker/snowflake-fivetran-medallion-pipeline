{{ config(materialized='table') }}

with contracts as (
    select * from {{ ref('stg_contracts') }}
),

transactions as (
    select * from {{ ref('fct_transactions') }}
),

mapping as (
    select * from {{ ref('arr_mapping_seed') }}
),

contract_mapping as (
    select
        c.contract_id,
        c.customer_id,
        c.contract_type,
        coalesce(m.billing_frequency, 'Unknown') as billing_frequency,
        coalesce(m.is_recurring, false) as is_recurring,
        coalesce(m.arr_tag, 'UNCLASSIFIED') as arr_tag,
        coalesce(m.arr_multiplier, 0) as arr_multiplier,
        c.contract_status,
        c.start_date,
        c.end_date
    from contracts c
    left join mapping m
        on lower(trim(c.contract_type)) = lower(trim(m.contract_type))
),

contract_revenue as (
    select
        customer_id,
        contract_id,
        contract_type,
        billing_frequency,
        is_recurring,
        arr_tag,
        arr_multiplier,
        contract_status,
        start_date,
        end_date,
        case
            when is_recurring = true and contract_status = 'Active' then 1
            else 0
        end as include_in_arr,
        case
            when is_recurring = true and contract_status = 'Active' then 1
            else 0
        end as recurring_contract_flag
    from contract_mapping
),

transaction_arr as (
    select
        t.customer_id,
        t.contract_id,
        sum(case when t.payment_status = 'Success' then t.amount else 0 end) as successful_amount,
        sum(case when t.payment_status = 'Failed' then t.amount else 0 end) as failed_amount
    from transactions t
    group by 1, 2
),

final as (
    select
        cr.customer_id,
        cr.contract_id,
        cr.contract_type,
        cr.billing_frequency,
        cr.is_recurring,
        cr.arr_tag,
        cr.arr_multiplier,
        cr.contract_status,
        cr.include_in_arr,
        coalesce(ta.successful_amount, 0) as successful_revenue,
        case
            when cr.is_recurring = true and cr.contract_status = 'Active' then coalesce(ta.successful_amount, 0) * cr.arr_multiplier
            else 0
        end as annualized_arr_value
    from contract_revenue cr
    left join transaction_arr ta
        on cr.contract_id = ta.contract_id
)

select *
from final
