FROM apache/airflow:2.10.5

USER airflow

RUN pip install --no-cache-dir \
    duckdb \
    dbt-core \
    dbt-duckdb \
    pandas \
    sqlalchemy \
    psycopg2-binary \
    openpyxl \
    pyarrow \
    gdown