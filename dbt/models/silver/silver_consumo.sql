{{ config(materialized='table') }}

select
    CustomerID as id_cliente,
    try_cast(OrderCount as integer) as quantidade_pedidos,
    try_cast(CouponUsed as integer) as cupons_utilizados,
    try_cast(DaySinceLastOrder as integer) as dias_desde_ultimo_pedido,
    try_cast(CashbackAmount as double) as valor_cashback,
    try_cast(TotalSpent as double) as valor_total_gasto,
    try_cast(CustomerLifetimeValue as double) as valor_cliente_tempo_vida,
    try_cast(ReturnRate as double) as taxa_devolucao,
    case
        when lower(trim(replace(replace(LastPurchaseCategory, '"', ''), chr(9), ''))) = 'electronics' then 'eletronicos'
        when lower(trim(replace(replace(LastPurchaseCategory, '"', ''), chr(9), ''))) = 'grocery' then 'mercado'
        when lower(trim(replace(replace(LastPurchaseCategory, '"', ''), chr(9), ''))) = 'fashion' then 'moda'
        when lower(trim(replace(replace(LastPurchaseCategory, '"', ''), chr(9), ''))) = 'laptop & accessory' then 'notebook_acessorios'
        when lower(trim(replace(replace(LastPurchaseCategory, '"', ''), chr(9), ''))) = 'beauty & personal care' then 'beleza_cuidados_pessoais'
        when lower(trim(replace(replace(LastPurchaseCategory, '"', ''), chr(9), ''))) = 'home & kitchen' then 'casa_cozinha'
        when lower(trim(replace(replace(LastPurchaseCategory, '"', ''), chr(9), ''))) = 'sports & fitness' then 'esportes_fitness'
        when lower(trim(replace(replace(LastPurchaseCategory, '"', ''), chr(9), ''))) = 'books' then 'livros'
        else 'nao_informado'
    end as categoria_ultima_compra,
    -- as datas chegam em vários formatos: aaaa-mm-dd, dd-mm-aaaa, dd.mm.aaaa e, com barra,
    -- tanto dd/mm/aaaa (maioria) quanto mm/dd/aaaa (americano). Com barra, tenta dd/mm primeiro;
    -- mm/dd só é usado quando dd/mm é impossível (ex.: 02/22/2024). Datas ambíguas como
    -- 05/03/2024 são lidas como dd/mm, mesmo que algumas tenham vindo no formato americano.
    coalesce(
        try_strptime(RegistrationDate, '%Y-%m-%d'),
        try_strptime(RegistrationDate, '%d/%m/%Y'),
        try_strptime(RegistrationDate, '%m/%d/%Y'),
        try_strptime(RegistrationDate, '%d-%m-%Y'),
        try_strptime(RegistrationDate, '%d.%m.%Y')
    )::date as data_cadastro,
    coalesce(
        try_strptime(LastPurchaseDate, '%Y-%m-%d'),
        try_strptime(LastPurchaseDate, '%d/%m/%Y'),
        try_strptime(LastPurchaseDate, '%m/%d/%Y'),
        try_strptime(LastPurchaseDate, '%d-%m-%Y'),
        try_strptime(LastPurchaseDate, '%d.%m.%Y')
    )::date as data_ultima_compra

from {{ source('bronze', 'ecommerce') }}