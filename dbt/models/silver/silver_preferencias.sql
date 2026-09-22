{{ config(materialized='table') }}

select
    CustomerID as id_cliente,
    case
        when lower(trim(replace(replace(PreferredLoginDevice, '"', ''), chr(9), ''))) = 'computer'
            then 'computador'
        when lower(trim(replace(replace(PreferredLoginDevice, '"', ''), chr(9), ''))) = 'mobile phone'
            then 'celular'
        when lower(trim(replace(replace(PreferredLoginDevice, '"', ''), chr(9), ''))) = 'tablet'
            then 'tablet'
        else 'nao_informado'
    end as dispositivo_login_preferido,
    case
        when lower(trim(regexp_replace(replace(replace(PreferredPaymentMode, '"', ''), chr(9), ''), '\s+', ' ', 'g')))
            in ('credit card', 'creditcard', 'cartão de crédito')
            then 'cartao_credito'
        when lower(trim(regexp_replace(replace(replace(PreferredPaymentMode, '"', ''), chr(9), ''), '\s+', ' ', 'g')))
            in ('debit card', 'cartão de débito')
            then 'cartao_debito'
        when lower(trim(regexp_replace(replace(replace(PreferredPaymentMode, '"', ''), chr(9), ''), '\s+', ' ', 'g')))
            in ('boleto', 'bol')
            then 'boleto'
        when lower(trim(regexp_replace(replace(replace(PreferredPaymentMode, '"', ''), chr(9), ''), '\s+', ' ', 'g')))
            in ('e-wallet', 'e wallet', 'ewallet')
            then 'carteira_digital'
        when lower(trim(regexp_replace(replace(replace(PreferredPaymentMode, '"', ''), chr(9), ''), '\s+', ' ', 'g'))) = 'pix'
            then 'pix'
        else 'nao_informado'
    end as forma_pagamento_preferida,
    case
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'mobile phone'
            then 'celular'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'electronics'
            then 'eletronicos'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'others'
            then 'outros'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'sports & fitness'
            then 'esportes_e_fitness'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'fashion'
            then 'moda'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'books'
            then 'livros'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'home & kitchen'
            then 'casa_e_cozinha'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'beauty & personal care'
            then 'beleza_e_cuidados_pessoais'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'laptop & accessory'
            then 'notebook_e_acessorios'
        when lower(trim(replace(replace(PreferedOrderCat, '"', ''), chr(9), ''))) = 'grocery'
            then 'mercado'
        else 'nao_informado'
    end as categoria_pedido_preferida,
    case
        when lower(trim(replace(replace(PreferredDeliveryTime, '"', ''), chr(9), ''))) = 'morning'
            then 'manha'
        when lower(trim(replace(replace(PreferredDeliveryTime, '"', ''), chr(9), ''))) = 'afternoon'
            then 'tarde'
        when lower(trim(replace(replace(PreferredDeliveryTime, '"', ''), chr(9), ''))) = 'evening'
            then 'noite'
        when lower(trim(replace(replace(PreferredDeliveryTime, '"', ''), chr(9), ''))) = 'night'
            then 'madrugada'
        else 'nao_informado'
    end as horario_entrega_preferido,
    case
        when try_cast(HourSpendOnApp as double) > 24 then null
        when try_cast(HourSpendOnApp as double) < 0 then null
        else try_cast(HourSpendOnApp as double)
    end as horas_no_app,
    try_cast(NumberOfDeviceRegistered as integer) as quantidade_dispositivos_registrados,
    try_cast(AppRating as double) as avaliacao_app,
    try_cast(EmailSubscribed as integer) as inscrito_email,
    try_cast(PushNotificationsEnabled as integer) as notificacoes_push_ativas

from {{ source('bronze', 'ecommerce') }}