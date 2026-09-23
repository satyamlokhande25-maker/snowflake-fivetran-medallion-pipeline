{{ config(materialized='table') }}

with arr as (
    select * from {{ ref('arr_revenue') }}
),

final as (
    select
        customer_id,
        sum(annualized_arr_value) as total_arr_value,
        sum(case when arr_tag = 'RECURRING' then annualized_arr_value else 0 end) as recurring_arr_value,
        max(case when arr_tag = 'RECURRING' then 1 else 0 end) as has_recurring_arr
    from arr
    where include_in_arr = 1
    group by customer_id
)

select * from final
