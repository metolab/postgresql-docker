#!/bin/bash
set -e

# Check if extension files exist
if [ ! -f "/usr/share/postgresql/$(pg_config --version | awk '{print $2}' | cut -d. -f1)/extension/roaringbitmap.control" ]; then
    echo "Error: roaringbitmap extension files not found"
    echo "Available extensions:"
    ls /usr/share/postgresql/*/extension/ | grep -E "\.control$" || echo "No extension control files found"
    exit 1
fi

# Enable pg_roaringbitmap extension
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS roaringbitmap;
EOSQL

echo "pg_roaringbitmap extension enabled successfully"