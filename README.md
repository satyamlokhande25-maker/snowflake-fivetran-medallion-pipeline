<div align="center">

# 🏔️ Enterprise Medallion ELT Data Pipeline

### dbt Core · Snowflake · Fivetran · Neon PostgreSQL

[![dbt](https://img.shields.io/badge/dbt--core-1.12.x-FF694B?logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![Snowflake](https://img.shields.io/badge/Warehouse-Snowflake-29B5E8?logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![Fivetran](https://img.shields.io/badge/Ingestion-Fivetran-blue)](https://www.fivetran.com/)
[![Postgres](https://img.shields.io/badge/Source-Neon%20PostgreSQL-336791?logo=postgresql&logoColor=white)](https://neon.tech/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An end-to-end modern data stack ELT pipeline implementing the **Medallion Architecture** — **Bronze (Staging)**, **Silver (Intermediate / Normalized)**, and **Gold (Marts / Analytics)** — built on **Neon PostgreSQL**, **Fivetran**, **Snowflake**, and **dbt Core**.

</div>

---

## 📑 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Medallion Data Flow](#medallion-data-flow)
- [Tech Stack & Tooling](#tech-stack--tooling)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Testing & Data Integrity](#testing--data-integrity)
- [License](#license)

---

## Architecture Overview

```text
[ Neon PostgreSQL ]
        │
        ▼ (Automated CDC / ELT Ingestion via Fivetran)
[ Snowflake: SATYAM."public" ] (Raw Ingested Layer)
        │
        ▼ (Bronze Layer: dbt Views, Identifiers quoting & Soft-Delete Filtering)
  ├── stg_customers
  ├── stg_contracts
  └── stg_transactions
        │
        ▼ (Silver Layer: Persistent Tables, Clean Dimensions & Facts)
  ├── dim_customers     (Customer Profiles & Active Contract Metrics)
  └── fct_transactions  (Enriched Transactions with Contract Attribution)
        │
        ▼ (Gold Layer: Business Aggregation Marts for BI & Executive Dashboards)
  ├── monthly_revenue_summary (Collection Performance & Success / Failure Rates)
  └── customer_lifetime_value (Customer Spend & Historical Retention KPIs)
```

---

## Medallion Data Flow

### 🥉 1. Bronze Layer (Staging)

- **Ingestion Source:** Raw tables ingested from Neon PostgreSQL via Fivetran into Snowflake schema `SATYAM."public"`.
- **Case-Sensitivity Handling:** Handled PostgreSQL-to-Snowflake lowercase naming collision using explicit quoting parameters in `sources.yml`.
- **Soft-Deletion Enforcement:** Integrated Fivetran metadata filtering using `coalesce(_fivetran_deleted, false) = false` to guarantee downstream models only receive active records.

**Models:**
- `stg_customers`: Standardized customer base view.
- `stg_contracts`: Standardized contract status view.
- `stg_transactions`: Cleaned base financial transactions.

### 🥈 2. Silver Layer (Intermediate / Normalized)

- **Design Pattern:** Modeled as Kimball-style Dimensions and Facts materialized as persistent Snowflake tables.

**Models:**
- `dim_customers`: Left joins customer staging with contract aggregations to calculate `total_contracts` and `active_contracts` per entity.
- `fct_transactions`: Fact table joining transaction events with contractual terms to expose `contract_type`, transaction day, and payment statuses.

### 🥇 3. Gold Layer (Business Marts)

- **Design Pattern:** Highly indexed and aggregated presentation layer optimized for direct dashboard consumption (Tableau, Power BI, Metabase).

**Models:**
- `monthly_revenue_summary`: Monthly granular breakdown of transaction volumes, total successful collections, and total failed revenue by contract type and payment channel.
- `customer_lifetime_value`: Analytical mart tracking customer-level lifetime revenue (LTV), transaction frequency, first acquisition date, and recent transaction timestamps.

---

---

## Tech Stack & Tooling

| Component | Tool |
|---|---|
| Source Database | Neon PostgreSQL |
| Ingestion Engine | Fivetran (Automated schema sync & CDC) |
| Cloud Data Warehouse | Snowflake (Role: `SYSADMIN`, Warehouse: `COMPUTE_WH`) |
| Transformation Framework | dbt Core (Snowflake Adapter 1.12.x) |
| Data Quality & Testing | Schema constraints (`unique`, `not_null`) across all pipeline layers |

---

---

## Project Structure

```text
satyam_medallion_pipeline/
├── dbt_project.yml
├── profiles.yml                 # Local connection profile (Kept private)
├── models/
│   ├── bronze/
│   │   ├── sources.yml          # Raw table definitions with identifier quoting
│   │   ├── schema.yml           # Bronze layer schema assertions & data tests
│   │   ├── stg_customers.sql
│   │   ├── stg_contracts.sql
│   │   └── stg_transactions.sql
│   ├── silver/
│   │   ├── schema.yml           # Silver layer primary key & null testing
│   │   ├── dim_customers.sql
│   │   └── fct_transactions.sql
│   └── gold/
│       ├── schema.yml           # Gold layer KPI validation tests
│       ├── monthly_revenue_summary.sql
│       └── customer_lifetime_value.sql
└── README.md
```

---

---

## Getting Started

### Prerequisites

- Python 3.10+ installed
- Snowflake account with `SYSADMIN` or assigned project role
- Fivetran connector configured from Neon PostgreSQL to Snowflake

### Setup & Execution

**1. Clone the repository:**

```bash
git clone https://github.com/satyamlokhande25-maker/snowflake-fivetran-medallion-pipeline.git
cd snowflake-fivetran-medallion-pipeline
```

**2. Configure local `profiles.yml` (`~/.dbt/profiles.yml`):**

```yaml
satyam_medallion_pipeline:
  outputs:
    dev:
      type: snowflake
      account: <YOUR_SNOWFLAKE_ACCOUNT>
      user: <YOUR_USERNAME>
      password: '<YOUR_PASSWORD>'
      role: SYSADMIN
      database: SATYAM
      warehouse: COMPUTE_WH
      schema: DBT_DEV
      threads: 4
  target: dev
```

**3. Validate pipeline connectivity:**

```bash
dbt debug
```

**4. Build and execute all layers:**

```bash
# Build all models across Bronze, Silver, and Gold
dbt run

# Execute schema validations and referential integrity tests
dbt test
```

**5. Generate documentation and lineage DAG:**

```bash
dbt docs generate
dbt docs serve
```

---

---

## Testing & Data Integrity

Data assertions are configured at each layer within the respective `schema.yml` manifests:

- ✅ **Unique & Not Null Tests:** Applied across primary keys (`customer_id`, `contract_id`, `transaction_id`) to prevent fan-out anomalies.
- ✅ **Referential & Metric Consistency:** Validating revenue aggregations and transaction mappings across transformations.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](../../issues) or open a pull request.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built with ❤️ using dbt, Snowflake & Fivetran

</div>
