FROM postgres:17.0

# Install build deps
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    ca-certificates \
    postgresql-server-dev-17 \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# -------------------
# Install pgvector 0.8.0
# -------------------
RUN git clone --branch v0.8.0 https://github.com/pgvector/pgvector.git /tmp/pgvector \
    && cd /tmp/pgvector \
    && make && make install \
    && rm -rf /tmp/pgvector

# -------------------
# Install VectorChord 0.4.3 (official repo)
# -------------------
RUN git clone --branch v0.4.3 https://github.com/VectorChord/vchord.git /tmp/vchord \
    && cd /tmp/vchord \
    && make && make install \
    && rm -rf /tmp/vchord

# -------------------
# Install PostGIS 3.5.0
# -------------------
RUN apt-get update && apt-get install -y \
    postgresql-17-postgis-3=3.5.0+dfsg-1~exp1.pgdg120+1 \
    postgresql-17-postgis-3-scripts=3.5.0+dfsg-1~exp1.pgdg120+1 \
    && rm -rf /var/lib/apt/lists/*

# -------------------
# Copy init scripts
# -------------------
COPY init-extensions.sql /docker-entrypoint-initdb.d/01-init-extensions.sql
COPY check-extensions.sh /docker-entrypoint-initdb.d/00-check-extensions.sh
RUN chmod +x /docker-entrypoint-initdb.d/00-check-extensions.sh

# Default Postgres envs (override in compose)
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=changeme
ENV POSTGRES_DB=postgres
