{{ config(materialized='table') }}

select
    CustomerID as id_cliente,

    case
        when lower(trim(replace(replace(Gender, '"', ''), chr(9), ''))) in ('female', 'feminino', 'f') 
            then 'feminino'
        when lower(trim(replace(replace(Gender, '"', ''), chr(9), ''))) in ('male', 'masculino', 'm') 
            then 'masculino'
        when lower(trim(replace(replace(Gender, '"', ''), chr(9), ''))) in ('non binary', 'non-binary', 'não-binário', 'nb') 
            then 'nao_binario'
        when lower(trim(replace(replace(Gender, '"', ''), chr(9), ''))) in ('prefer not to say', 'pnts') 
            then 'prefere_nao_informar'
        else 'nao_informado'
    end as genero,

    case
        when try_cast(Age as integer) < 0 then null
        when try_cast(Age as integer) > 100 then null
        else try_cast(Age as integer)   
    end as idade,

    lower(
        trim(
            regexp_replace(
                replace(replace(City, '"', ''), chr(9), ''),
                '\s+',
                ' ',
                'g'
            )
        )
    ) as cidade,

    case
        when lower(trim(regexp_replace(replace(replace(IncomeRange, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) 
            in ('baixa (até r$ 3.000)', 'baixa (até r$ 3000)')
            then 'baixa'
        when lower(trim(regexp_replace(replace(replace(IncomeRange, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) 
            in ('média-baixa (r$ 3.001 - 6.000)', 'média-baixa (r$ 3001 - 6000)')
            then 'media_baixa'
        when lower(trim(regexp_replace(replace(replace(IncomeRange, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) 
            in ('média (r$ 6.001 - 10.000)', 'média (r$ 6001 - 10000)')
            then 'media'
        when lower(trim(regexp_replace(replace(replace(IncomeRange, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) 
            in ('média-alta (r$ 10.001 - 15.000)', 'média-alta (r$ 10001 - 15000)')
            then 'media_alta'
        when lower(trim(regexp_replace(replace(replace(IncomeRange, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) 
            in ('alta (acima de r$ 15.000)', 'alta (acima de r$ 15000)')
            then 'alta'
        when trim(replace(replace(IncomeRange, '"', ''), chr(9), '')) in ('0.0', '99999.99', '9999.99')
            then 'nao_informado'
        else 'nao_informado'
    end as faixa_renda,

    case
        when lower(trim(regexp_replace(replace(replace(EducationLevel, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'ensino fundamental'
            then 'ensino_fundamental'
        when lower(trim(regexp_replace(replace(replace(EducationLevel, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'ensino médio'
            then 'ensino_medio'
        when lower(trim(regexp_replace(replace(replace(EducationLevel, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'superior incompleto'
            then 'superior_incompleto'
        when lower(trim(regexp_replace(replace(replace(EducationLevel, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'superior completo'
            then 'superior_completo'
        when lower(trim(regexp_replace(replace(replace(EducationLevel, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'pós-graduação'
            then 'pos_graduacao'
        else 'nao_informado'
    end as nivel_educacao,

    lower(trim(replace(replace(Occupation, '"', ''), chr(9), ''))) as ocupacao,

    case
        when lower(trim(regexp_replace(replace(replace(MaritalStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) in ('single', 'solteiro')
            then 'solteiro'
        when lower(trim(regexp_replace(replace(replace(MaritalStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) in ('married', 'casado')
            then 'casado'
        when lower(trim(regexp_replace(replace(replace(MaritalStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) in ('divorced', 'divorciado')
            then 'divorciado'
        when lower(trim(regexp_replace(replace(replace(MaritalStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) in ('widowed', 'viúvo')
            then 'viuvo'
        when lower(trim(regexp_replace(replace(replace(MaritalStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) in ('domestic partnership', 'união estável')
            then 'uniao_estavel'
        else 'nao_informado'
    end as estado_civil,

    case
        when lower(trim(replace(replace(HasChildren, '"', ''), chr(9), ''))) in ('1', 'true', 'yes', 'y', 'sim')
            then 1
        when lower(trim(replace(replace(HasChildren, '"', ''), chr(9), ''))) in ('0', 'false', 'no', 'n', 'não', 'nao')
            then 0
        else null
    end as possui_filhos,

    NumberOfChildren as quantidade_filhos,

    case
        when lower(trim(regexp_replace(replace(replace(EmploymentStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) in ('empregado tempo integral', 'full-time employed')
            then 'empregado_tempo_integral'
        when lower(trim(regexp_replace(replace(replace(EmploymentStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) in ('empregado meio período', 'part-time employed')
            then 'empregado_meio_periodo'
        when lower(trim(regexp_replace(replace(replace(EmploymentStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'desempregado'
            then 'desempregado'
        when lower(trim(regexp_replace(replace(replace(EmploymentStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'estudante'
            then 'estudante'
        when lower(trim(regexp_replace(replace(replace(EmploymentStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'autônomo'
            then 'autonomo'
        when lower(trim(regexp_replace(replace(replace(EmploymentStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'aposentado'
            then 'aposentado'
        when lower(trim(regexp_replace(replace(replace(EmploymentStatus, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) in ('não sei', 'n/d', '???')
            then 'nao_informado'
        else 'nao_informado'
    end as status_emprego

from {{ source('bronze', 'ecommerce') }}