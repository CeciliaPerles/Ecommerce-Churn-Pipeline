FROM apache/superset:latest

USER root

# A imagem oficial não traz o driver do DuckDB
RUN . /app/.venv/bin/activate && \
    uv pip install --no-cache duckdb-engine

USER superset
