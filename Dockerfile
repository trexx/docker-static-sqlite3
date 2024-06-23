FROM alpine:3.20.1@sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0
LABEL org.opencontainers.image.source https://github.com/trexx/docker-vaultwarden-backup

# renovate: datasource=repology depName=alpine_3_20/sqlite versioning=loose
ENV SQLITE_VERSION "3.45.3-r1"

RUN apk --update --no-cache add sqlite="${SQLITE_VERSION}"