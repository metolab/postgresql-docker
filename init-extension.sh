#!/bin/bash
set -e

# Show PostgreSQL version and extension directory info
echo "PostgreSQL version: $(pg_config --version)"
echo "Extension directory: $(pg_config --sharedir)/extension"
echo "Library directory: $(pg_config --pkglibdir)"

# List roaringbitmap files in all possible locations
echo "Looking for roaringbitmap files..."
find /usr/share/postgresql -name "roaringbitmap*" 2>/dev/null | head -10
find /usr/lib/postgresql -name "roaringbitmap*" 2>/dev/null | head -10

# Enable pg_roaringbitmap extension
echo "Attempting to create roaringbitmap extension..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS roaringbitmap;
    SELECT 'pg_roaringbitmap extension created successfully' as result;
    SELECT roaringbitmap_version();
EOSQL

echo "pg_roaringbitmap extension enabled successfully"