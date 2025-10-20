ARG POSTGRES_VERSION=17
FROM postgres:${POSTGRES_VERSION}-bookworm AS builder

ARG POSTGRES_VERSION
ARG ROARINGBITMAP_VERSION=0.5.5

# Install build dependencies in a single layer with proper cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        unzip \
        make \
        gcc \
        postgresql-server-dev-${POSTGRES_VERSION} && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and extract extension
WORKDIR /tmp
RUN curl -fsSL -o "roaringbitmap.zip" \
    "https://github.com/ChenHuajun/pg_roaringbitmap/archive/refs/tags/v${ROARINGBITMAP_VERSION}.zip" && \
    unzip -q "roaringbitmap.zip" && \
    rm -f "roaringbitmap.zip"

# Build and install extension
WORKDIR "/tmp/pg_roaringbitmap-${ROARINGBITMAP_VERSION}"
RUN make -f Makefile_native && make install && \
    make clean && \
    rm -rf /tmp/*

# Final image
FROM postgres:${POSTGRES_VERSION}-bookworm
ARG POSTGRES_VERSION

# Copy extension files from builder stage
COPY --from=builder /usr/share/postgresql/${POSTGRES_VERSION}/extension/roaringbitmap* /usr/share/postgresql/${POSTGRES_VERSION}/extension/
COPY --from=builder /usr/lib/postgresql/${POSTGRES_VERSION}/lib/roaringbitmap.so /usr/lib/postgresql/${POSTGRES_VERSION}/lib/
COPY --from=builder /usr/lib/postgresql/${POSTGRES_VERSION}/lib/bitcode/roaringbitmap /usr/lib/postgresql/${POSTGRES_VERSION}/lib/bitcode/roaringbitmap
COPY --from=builder /usr/lib/postgresql/${POSTGRES_VERSION}/lib/bitcode/roaringbitmap.index.bc /usr/lib/postgresql/${POSTGRES_VERSION}/lib/bitcode/roaringbitmap.index.bc

# Add init script to create extension automatically
COPY --chmod=755 load-extension.sql /docker-entrypoint-initdb.d/

# Set proper ownership for PostgreSQL data directory
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pg_isready -U postgres || exit 1