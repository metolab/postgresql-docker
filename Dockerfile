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

# Clean up build dependencies
RUN apt-get remove -y build-essential git pkg-config libssl-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy initialization scripts
COPY init-extension.sh /docker-entrypoint-initdb.d/init-extension.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-extension.sh

# Set the default command
CMD ["postgres"]