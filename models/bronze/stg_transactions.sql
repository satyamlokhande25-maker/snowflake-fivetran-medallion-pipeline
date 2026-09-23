with source as (
    select * from {{ source('ecommerce', 'transactions') }}
),

renamed as (
    select
        "transaction_id" as transaction_id,
        "contract_id" as contract_id,
        "customer_id" as customer_id,
        "amount" as amount,
        "payment_method" as payment_method,
        "payment_status" as payment_status,
        "transaction_date" as transaction_date,
        "created_at" as created_at,
        "_fivetran_synced" as _fivetran_synced
    from source
    where coalesce("_fivetran_deleted", false) = false
)

select * from renamed