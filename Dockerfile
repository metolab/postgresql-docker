ARG POSTGRES_VERSION=15
FROM postgres:${POSTGRES_VERSION}

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    pkg-config \
    libssl-dev \
    postgresql-server-dev-all \
    && rm -rf /var/lib/apt/lists/*

# Clone and build pg_roaringbitmap
RUN cd /tmp && \
    git clone --depth 1 https://github.com/ChenHuajun/pg_roaringbitmap.git && \
    cd pg_roaringbitmap && \
    make clean && \
    make USE_PGXS=1 && \
    make install USE_PGXS=1 && \
    cd / && \
    rm -rf /tmp/pg_roaringbitmap

# Ensure extension files are in the correct PostgreSQL directory
RUN find /usr/share/postgresql -name "roaringbitmap.control" -exec dirname {} \; | head -1 | xargs -I {} find {} -name "roaringbitmap*" -exec cp -v {} /usr/share/postgresql/${POSTGRES_VERSION}/extension/ \; && \
    find /usr/lib/postgresql -name "roaringbitmap.so" -exec dirname {} \; | head -1 | xargs -I {} cp -v {}/*.so /usr/lib/postgresql/${POSTGRES_VERSION}/lib/ 2>/dev/null || true

# Verify extension files are in the correct location
RUN ls -la /usr/share/postgresql/${POSTGRES_VERSION}/extension/roaringbitmap* && \
    ls -la /usr/lib/postgresql/${POSTGRES_VERSION}/lib/roaringbitmap* 2>/dev/null || echo "No shared library found"

# Clean up build dependencies
RUN apt-get remove -y build-essential git pkg-config libssl-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy initialization scripts
COPY init-extension.sh /docker-entrypoint-initdb.d/init-extension.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-extension.sh

# Set the default command
CMD ["postgres"]