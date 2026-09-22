FROM apache/superset:latest

USER root

# A imagem oficial não traz os drivers do DuckDB (dados) nem do Postgres (metadados)
RUN . /app/.venv/bin/activate && \
    uv pip install --no-cache duckdb-engine psycopg2-binary

COPY superset_config.py /app/pythonpath/superset_config.py

USER superset
