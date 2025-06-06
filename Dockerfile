ARG CRUNCHYDATA_VERSION
ARG VECTORCHORD_VERSION
ARG PG_MAJOR

FROM ubuntu:latest AS builder

RUN apt-get update && apt-get install -y curl binutils unzip

ARG VECTORCHORD_VERSION
ARG PG_MAJOR

RUN curl --fail -o vchord.zip -sSL https://github.com/tensorchord/VectorChord/releases/download/${VECTORCHORD_VERSION}/postgresql-${PG_MAJOR}-vchord_${VECTORCHORD_VERSION}_x86_64-linux-gnu.zip \
  && unzip -d vchord_raw vchord.zip \
  && mkdir -p /vchord \
  && if [ -d "vchord_raw/pkglibdir" ]; then \
  cp vchord_raw/pkglibdir/vchord.so /vchord/ && \
  cp vchord_raw/sharedir/extension/vchord*.sql /vchord/ && \
  cp vchord_raw/sharedir/extension/vchord.control /vchord/ ; \
  else \
  cp vchord_raw/vchord.so /vchord/ && \
  cp vchord_raw/vchord*.sql /vchord/ && \
  cp vchord_raw/vchord.control /vchord/ ; \
  fi

ARG CRUNCHYDATA_VERSION
FROM registry.developers.crunchydata.com/crunchydata/crunchy-postgres:${CRUNCHYDATA_VERSION:-ubi9-16.8-2516}

ARG PG_MAJOR

COPY --chown=root:root --chmod=755 --from=builder /vchord/vchord.so /usr/pgsql-${PG_MAJOR}/lib/
COPY --chown=root:root --chmod=755 --from=builder /vchord/vchord*.sql /usr/pgsql-${PG_MAJOR}/share/extension/
COPY --chown=root:root --chmod=755 --from=builder /vchord/vchord.control /usr/pgsql-${PG_MAJOR}/share/extension/
