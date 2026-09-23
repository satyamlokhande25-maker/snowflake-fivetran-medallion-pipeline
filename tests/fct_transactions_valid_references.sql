select
    t.transaction_id,
    t.customer_id,
    t.contract_id
from {{ ref('fct_transactions') }} t
left join {{ ref('stg_customers') }} c on t.customer_id = c.customer_id
left join {{ ref('stg_contracts') }} ct on t.contract_id = ct.contract_id
where t.customer_id is null
   or t.contract_id is null
   or c.customer_id is null
   or ct.contract_id is null
