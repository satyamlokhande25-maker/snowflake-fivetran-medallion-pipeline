select
    customer_id,
    total_contracts,
    active_contracts
from {{ ref('dim_customers') }}
where active_contracts > total_contracts
