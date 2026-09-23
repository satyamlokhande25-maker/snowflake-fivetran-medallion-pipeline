with source as (
    select * from {{ source('ecommerce', 'customers') }}
),

renamed as (
    select
        "customer_id" as customer_id,
        "name" as customer_name,
        "email" as email,
        "city" as city,
        "created_at" as created_at,
        "updated_at" as updated_at,
        "_fivetran_synced" as _fivetran_synced
    from source
    where coalesce("_fivetran_deleted", false) = false
)

select * from renamed