# Ecommerce Churn Pipeline (Squad-Jane)

Pipeline de engenharia de dados que coleta uma base de clientes de e-commerce, limpa e padroniza os dados e monta tabelas para analisar **churn** (clientes que deixaram de comprar).

Stack: Airflow, Postgres, DuckDB, dbt e Superset, tudo em Docker.

## Como os dados fluem

```
Google Drive (CSV)
   │  DAG download_drive_csv        todo dia às 00h
   ▼
Postgres (source_db.public.ecommerce)
   │  DAG postgres_to_duckdb        dispara quando a anterior termina
   ▼
DuckDB (bronze.ecommerce)
   │  dbt run                       última tarefa da DAG postgres_to_duckdb
   ▼
DuckDB (silver_* e gold_*)
   │
   ▼
Superset (dashboards)
```

A DAG `postgres_to_duckdb` não tem horário próprio: ela é disparada pelo Airflow (via [Dataset](https://airflow.apache.org/docs/apache-airflow/2.10.5/authoring-and-scheduling/datasets.html)) sempre que `download_drive_csv` termina de gravar no Postgres.

## Como rodar

```bash
docker compose up -d --build
```

| Serviço  | Endereço              | Login         |
|----------|-----------------------|---------------|
| Airflow  | http://localhost:8080 | admin / admin |
| Superset | http://localhost:8088 | admin / admin |
| Postgres de origem | localhost:5432 | source_user / source_pass |

1. No Airflow, ative as duas DAGs (elas começam pausadas).
2. Rode `download_drive_csv` manualmente ou espere a meia-noite. `postgres_to_duckdb` roda sozinha em seguida.
3. No Superset, em *Settings → Database Connections → + Database → DuckDB*, use:
   - SQLAlchemy URI: `duckdb:////app/duckdb/warehouse.duckdb`
   - *Advanced → Other → Engine Parameters*: `{"connect_args": {"read_only": true}}`

   O modo somente leitura evita que o Superset bloqueie o arquivo enquanto o dbt grava nele.

Para rodar só o dbt, sem passar pelas DAGs:

```bash
docker compose exec airflow_scheduler dbt run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt
```

## Tabelas

**Bronze** (`bronze.ecommerce`): cópia fiel do CSV, sem tratamento. Carregada pela DAG, declarada no dbt como *source*.

**Silver**: limpeza e padronização, uma tabela por tema. Os valores são traduzidos e padronizados (ex.: churn chega como `1`, `Sim`, `Y`, `True`... e vira `1`), aspas e tabs são removidos e valores impossíveis viram nulo (idade acima de 100, nota fora de 1 a 5, distância 9999).

| Tabela | Conteúdo |
|---|---|
| `silver_status` | churn, tempo como cliente, satisfação, reclamação, distância do estoque |
| `silver_perfil` | gênero, idade, cidade, renda, escolaridade, estado civil, filhos, emprego |
| `silver_preferencias` | dispositivo, forma de pagamento, categoria preferida, horário de entrega, uso do app |
| `silver_consumo` | pedidos, cupons, cashback, gastos, devoluções, datas de cadastro e última compra |
| `silver_ecommerce` | cópia da bronze |

**Gold**: tabelas prontas para análise.

| Tabela | Conteúdo |
|---|---|
| `gold_abt_churn_cliente` | uma linha por cliente com todas as colunas da silver e indicadores calculados: ticket médio, frequência mensal de compra, eficiência do cashback, perfil problemático e cliente inativo (mais de 30 dias sem comprar) |
| `gold_kpis_churn` | uma linha com os números gerais: taxa de churn, CLV médio, satisfação média, taxa de reclamação |
| `gold_churn_analise` | taxa de churn e médias por categoria de cada dimensão (renda, gênero, escolaridade, emprego, categoria preferida, pagamento, dispositivo), uma dimensão por vez |

## Limitações conhecidas dos dados

As datas com barra chegam misturando o formato brasileiro (`dd/mm/aaaa`, a maioria) e o americano (`mm/dd/aaaa`). Quando a data só é válida em um dos formatos (ex.: `02/22/2024`), ela é convertida corretamente. Quando é válida nos dois (ex.: `05/03/2024`), é lida como `dd/mm/aaaa`, então parte dessas datas fica com dia e mês trocados. Na amostra analisada, isso afeta cerca de 4% dos clientes.
