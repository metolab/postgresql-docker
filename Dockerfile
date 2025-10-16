ARG POSTGRES_VERSION=17
FROM postgres:${POSTGRES_VERSION}-bookworm AS builder
ARG POSTGRES_VERSION

ENV ROARINGBITMAP_VERSION=0.5.5

WORKDIR /
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make gcc postgresql-server-dev-${POSTGRES_VERSION} && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL -o "v${ROARINGBITMAP_VERSION}.zip" "https://github.com/ChenHuajun/pg_roaringbitmap/archive/refs/tags/v${ROARINGBITMAP_VERSION}.zip"
RUN unzip -q "v${ROARINGBITMAP_VERSION}.zip" && rm -f "v${ROARINGBITMAP_VERSION}.zip"
WORKDIR "pg_roaringbitmap-${ROARINGBITMAP_VERSION}"
RUN make -f Makefile_native && make install

FROM postgres:${POSTGRES_VERSION}-bookworm
ARG POSTGRES_VERSION
COPY --from=builder /usr/share/postgresql/${POSTGRES_VERSION}/extension/roaringbitmap* /usr/share/postgresql/${POSTGRES_VERSION}/extension/
COPY --from=builder /usr/lib/postgresql/${POSTGRES_VERSION}/lib/roaringbitmap.so /usr/lib/postgresql/${POSTGRES_VERSION}/lib/
COPY --from=builder /usr/lib/postgresql/${POSTGRES_VERSION}/lib/bitcode/roaringbitmap /usr/lib/postgresql/${POSTGRES_VERSION}/lib/bitcode/roaringbitmap
COPY --from=builder /usr/lib/postgresql/${POSTGRES_VERSION}/lib/bitcode/roaringbitmap.index.bc /usr/lib/postgresql/${POSTGRES_VERSION}/lib/bitcode/roaringbitmap.index.bc

COPY load-extension.sql /docker-entrypoint-initdb.d/