{{ config(materialized='table') }}

-- Churn analisado uma dimensão por vez (ex.: dimensao = 'genero', categoria = 'feminino').
-- Cruzar todas as dimensões juntas gera milhares de grupos com 1 ou 2 clientes,
-- onde a taxa de churn fica sempre 0% ou 100% e não significa nada.

with base as (

    select
        s.churn,
        s.nota_satisfacao,
        c.valor_cliente_tempo_vida,
        c.valor_total_gasto,
        c.taxa_devolucao,
        pref.horas_no_app,

        p.faixa_renda,
        p.genero,
        p.nivel_educacao,
        p.status_emprego,
        pref.categoria_pedido_preferida,
        pref.forma_pagamento_preferida,
        pref.dispositivo_login_preferido

    from {{ ref('silver_status') }} s

    left join {{ ref('silver_perfil') }} p
        on s.id_cliente = p.id_cliente

    left join {{ ref('silver_preferencias') }} pref
        on s.id_cliente = pref.id_cliente

    left join {{ ref('silver_consumo') }} c
        on s.id_cliente = c.id_cliente

),

por_dimensao as (

    unpivot base
    on
        faixa_renda,
        genero,
        nivel_educacao,
        status_emprego,
        categoria_pedido_preferida,
        forma_pagamento_preferida,
        dispositivo_login_preferido
    into
        name dimensao
        value categoria

)

select
    dimensao,
    categoria,

    count(*) as total_clientes,

    sum(case when churn = 1 then 1 else 0 end) as clientes_churn,

    round(
        sum(case when churn = 1 then 1 else 0 end) * 1.0 / count(*),
        4
    ) as taxa_churn,

    round(avg(valor_cliente_tempo_vida), 2) as media_clv,
    round(avg(nota_satisfacao), 2) as media_satisfacao,
    round(avg(valor_total_gasto), 2) as media_total_gasto,
    round(avg(taxa_devolucao), 4) as media_taxa_devolucao,
    round(avg(horas_no_app), 2) as media_horas_no_app

from por_dimensao

group by
    dimensao,
    categoria
