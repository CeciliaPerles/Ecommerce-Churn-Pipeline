import os

# Guarda usuários, dashboards e gráficos no Postgres do serviço postgres_superset.
# Sem este arquivo, o Superset ignora as variáveis DATABASE_* e usa um SQLite
# dentro do container.
SQLALCHEMY_DATABASE_URI = (
    f"{os.environ['DATABASE_DIALECT']}://"
    f"{os.environ['DATABASE_USER']}:{os.environ['DATABASE_PASSWORD']}"
    f"@{os.environ['DATABASE_HOST']}:{os.environ['DATABASE_PORT']}"
    f"/{os.environ['DATABASE_DB']}"
)
