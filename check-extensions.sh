#!/bin/bash
set -e

# Expected pinned versions
EXPECTED_PGVECTOR="0.8.0"
EXPECTED_VCHORD="0.4.3"
EXPECTED_POSTGIS="3.5.0"

echo "🔍 Checking installed PostgreSQL extensions..."

# Start temporary Postgres to check extensions
pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" -w start

check_extension() {
    local ext=$1
    local expected=$2
    local installed
    installed=$(psql -tAc "SELECT extversion FROM pg_extension WHERE extname='${ext}';" postgres || echo "not installed")

    if [[ "$installed" == "not installed" ]]; then
        echo "❌ Extension ${ext} not installed!"
        pg_ctl -D "$PGDATA" -m fast stop
        exit 1
    fi

    if [[ "$installed" != "$expected" ]]; then
        echo "❌ Extension ${ext} version mismatch! Expected ${expected}, found ${installed}"
        pg_ctl -D "$PGDATA" -m fast stop
        exit 1
    fi

    echo "✅ ${ext} version OK (${installed})"
}

check_extension "vector" "$EXPECTED_PGVECTOR"
check_extension "vchord" "$EXPECTED_VCHORD"
check_extension "postgis" "$EXPECTED_POSTGIS"

pg_ctl -D "$PGDATA" -m fast stop
echo "✅ All extensions match expected versions."
