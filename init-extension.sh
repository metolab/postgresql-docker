#!/bin/bash
set -e

# Enable pg_roaringbitmap extension
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS roaringbitmap;
EOSQL

echo "pg_roaringbitmap extension enabled successfully"