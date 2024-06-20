FROM alpine:3.20.1@sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0
LABEL org.opencontainers.image.source https://github.com/trexx/docker-vaultwarden-backup

# renovate: datasource=repology depName=alpine_3_19/sqlite versioning=loose
ENV SQLITE_VERSION "3.44.2-r0"

# renovate: datasource=repology depName=alpine_3_19/rsync versioning=loose
ENV RSYNC_VERSION "3.2.7-r4"

# renovate: datasource=repology depName=alpine_3_19/bash versioning=loose
ENV BASH_VERSION "5.2.21-r0"

RUN apk --update --no-cache add sqlite="${SQLITE_VERSION}" rsync="${RSYNC_VERSION}" bash="${BASH_VERSION}"

COPY /backup.sh / 