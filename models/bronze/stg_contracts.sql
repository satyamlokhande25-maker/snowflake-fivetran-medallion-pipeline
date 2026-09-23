with source as (
    select * from {{ source('ecommerce', 'contracts') }}
),

renamed as (
    select
        "contract_id" as contract_id,
        "customer_id" as customer_id,
        "contract_type" as contract_type,
        "start_date" as start_date,
        "end_date" as end_date,
        "status" as contract_status,
        "created_at" as created_at,
        "updated_at" as updated_at,
        "_fivetran_synced" as _fivetran_synced
    from source
    where coalesce("_fivetran_deleted", false) = false
)

select * from renamed