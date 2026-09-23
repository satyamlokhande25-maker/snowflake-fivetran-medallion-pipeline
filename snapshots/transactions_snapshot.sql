{% snapshot transactions_snapshot %}
    {{
        config(
            target_schema='PUBLIC',
            unique_key='"transaction_id"',
            strategy='timestamp',
            updated_at='"created_at"',
            invalidate_hard_deletes=True
        )
    }}

    select *
    from {{ source('ecommerce', 'transactions') }}
{% endsnapshot %}
