{{ config(materialized='table') }}

select
    CustomerID as id_cliente,
    case
        when lower(trim(replace(replace(Churn, '"', ''), chr(9), ''))) in ('1', 'true', 'yes', 'y', 'sim')
            then 1
        when lower(trim(replace(replace(Churn, '"', ''), chr(9), ''))) in ('0', 'false', 'no', 'n', 'não', 'nao')
            then 0
        else null
    end as churn,
    case
        when Tenure < 0 then null
        else Tenure
    end as tempo_como_cliente,
    case
        when SatisfactionScore not between 1 and 5 then null
        else SatisfactionScore
    end as nota_satisfacao,
    case
        when lower(trim(replace(replace(Complain, '"', ''), chr(9), ''))) in ('1', 'true', 'yes', 'y', 'sim')
            then 1
        when lower(trim(replace(replace(Complain, '"', ''), chr(9), ''))) in ('0', 'false', 'no', 'n', 'não', 'nao')
            then 0
        else null
    end as teve_reclamacao,
    CityTier as nivel_cidade,
    case
        when WarehouseToHome < 0 then null
        when WarehouseToHome = 9999 then null
        else WarehouseToHome
    end as distancia_estoque_residencia,
    NumberOfAddress as quantidade_enderecos

from {{ source('bronze', 'ecommerce') }}