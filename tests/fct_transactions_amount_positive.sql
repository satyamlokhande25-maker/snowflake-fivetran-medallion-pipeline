select
    transaction_id,
    amount
from {{ ref('fct_transactions') }}
where amount is null or amount <= 0
