{% snapshot contracts_snapshot %}
    {{
        config(
            target_schema='PUBLIC',
            unique_key='"contract_id"',
            strategy='timestamp',
            updated_at='"updated_at"',
            invalidate_hard_deletes=True
        )
    }}

    select *
    from {{ source('ecommerce', 'contracts') }}
{% endsnapshot %}
