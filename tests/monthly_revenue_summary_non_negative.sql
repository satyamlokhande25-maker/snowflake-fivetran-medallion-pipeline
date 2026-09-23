select
    transaction_month,
    contract_type,
    total_successful_revenue,
    total_failed_revenue
from {{ ref('monthly_revenue_summary') }}
where total_successful_revenue < 0
   or total_failed_revenue < 0
