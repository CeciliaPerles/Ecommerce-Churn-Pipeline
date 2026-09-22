{{ config(materialized='table') }}

select *
from {{ source('bronze', 'ecommerce') }}
