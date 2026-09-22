import duckdb
import pandas as pd
from sqlalchemy import create_engine
from airflow import DAG
from airflow.datasets import Dataset
from datetime import datetime
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import os

POSTGRES_CONN = "postgresql+psycopg2://source_user:source_pass@postgres_source:5432/source_db"
DUCKDB_PATH = "/opt/airflow/duckdb/warehouse.duckdb"
PARQUET_PATH = "/opt/airflow/tmp/ecommerce.parquet"
DBT_DIR = "/opt/airflow/dbt"

# Atualizada pela DAG download_drive_csv: esta DAG roda sempre que ela termina
ECOMMERCE_POSTGRES = Dataset("postgres://postgres_source:5432/source_db/public/ecommerce")

def inicio():
    print("Iniciando o processo.")

def coleta_postgres():
    print("Coletando dados no Postgres.")
    os.makedirs("/opt/airflow/tmp", exist_ok=True)
    engine = create_engine(POSTGRES_CONN)
    try:
        with engine.connect() as conn:
            df = pd.read_sql("SELECT * FROM ecommerce", conn)

        df.to_parquet(PARQUET_PATH, index=False)

    finally:
        engine.dispose()


def grava_duckdb():
    print("Gravando dados no DuckDB.")

    os.makedirs("/opt/airflow/duckdb", exist_ok=True)

    df = pd.read_parquet(PARQUET_PATH)

    conn_duckdb = duckdb.connect(DUCKDB_PATH)

    try:
        conn_duckdb.execute("CREATE SCHEMA IF NOT EXISTS bronze")

        conn_duckdb.register("ecommerce", df)

        conn_duckdb.execute("""
            CREATE OR REPLACE TABLE bronze.ecommerce AS
            SELECT *
            FROM ecommerce
        """)

    finally:
        conn_duckdb.close()

def fim():
    print("Processo finalizado com sucesso!")

with DAG(
    dag_id='postgres_to_duckdb',
    start_date=datetime(2026, 4, 29),
    schedule=[ECOMMERCE_POSTGRES],  # Executa quando download_drive_csv atualiza o Postgres
) as dag:

    inicio_processo = PythonOperator(
        task_id='inicio_processo',
        python_callable=inicio,
    )

    coleta_dados = PythonOperator(
        task_id='coleta_dados',
        python_callable=coleta_postgres,
    )

    processa_dados = PythonOperator(
        task_id='processa_dados',
        python_callable=grava_duckdb,
    )

    # Monta as camadas silver e gold a partir de bronze.ecommerce
    transforma_dados = BashOperator(
        task_id='transforma_dados',
        bash_command=f'dbt run --project-dir {DBT_DIR} --profiles-dir {DBT_DIR}',
    )

    fim_processo = PythonOperator(
        task_id='fim_processo',
        python_callable=fim,
    )

    # Encadeando as tarefas na ordem desejada
    inicio_processo >> coleta_dados >> processa_dados >> transforma_dados >> fim_processo
