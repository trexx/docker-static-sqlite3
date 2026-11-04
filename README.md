# docker-static-sqlite3

Alpine image with sqlite3 for backing up vaultwarden database. The image itself is empty apart from one statically compiled `sqlite3` binary built on Alpine, and is published to `ghcr.io/trexx/docker-static-sqlite3`.

## Overview

A statically compiled sqlite3 in an empty container image (~1.1 MB).

The [Dockerfile](Dockerfile) has two stages:

- `build` (`alpine:3.24.3`, pinned by digest) downloads the SQLite amalgamation (`sqlite-amalgamation-<SQLITE_VERSION>.zip` from sqlite.org, under the `SQLITE_YEAR` directory), installs `gcc`, `libarchive-tools` and `musl-dev`, and compiles `shell.c` and `sqlite3.c` with `-static -O2`, then strips the binary. It is a cut-down build: it is compiled with `SQLITE_THREADSAFE=0`, `SQLITE_DQS=0` and a long list of `SQLITE_OMIT_*` options, which leave out among others JSON, the date and time functions, `CHECK` constraints, foreign keys, `EXPLAIN`, `AUTOINCREMENT`, auto-vacuum, extension loading and UTF-16.
- The final image is `FROM scratch` and contains only `/sqlite3`.

The image has no shell and no entrypoint, so the command must call `/sqlite3` directly.

### Applications

I use this image as part of a Kubernetes Cronjob to run .backup against VaultWardens sqlite database. Volsync will then ship the PVC off to BackBlaze.

## Usage

Images are published as `ghcr.io/trexx/docker-static-sqlite3:<version>` and `ghcr.io/trexx/docker-static-sqlite3:latest`, where the version is the SQLite version (for example `3.54.1`).

Run `/sqlite3` against a database on a mounted volume, for example to make a backup:

```sh
docker run --rm -v "$PWD:/data" ghcr.io/trexx/docker-static-sqlite3:latest \
  /sqlite3 /data/db.sqlite3 ".backup /data/db.sqlite3.bak"
```

### Kubernetes Cronjob Example

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: ghcr.io/trexx/docker-static-sqlite3:3.46.0
            command:
              - /sqlite3
              - /data/db.sqlite3
              - .backup /data/db.sqlite3.bak
            volumeMounts:
              - mountPath: /data
                name: data
          restartPolicy: OnFailure
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: data-vaultwarden-0
```

## Development

Build the image locally with:

```sh
docker build .
```

Dependency updates:

- SQLite is not tracked by Renovate: sqlite.org names the amalgamation after a zero-padded release id (3.53.4 is `3530400`) and files it under the year it was published, neither of which Renovate can derive. Instead, [`.github/workflows/sqlite.yml`](.github/workflows/sqlite.yml) runs daily, reads the latest amalgamation from `https://www.sqlite.org/download.html`, updates `SQLITE_VERSION` and `SQLITE_YEAR` in the Dockerfile and opens an "Update SQLite to <version>" pull request on the `update/sqlite` branch.
- [Renovate](.github/renovate.json) keeps the Alpine base image digest and the GitHub Actions up to date.

Workflows in `.github/workflows`:

- `container-check.yml` runs hadolint on the Dockerfile and builds the image without pushing it, on pull requests and pushes to `main`.
- `trivy.yml` scans `ghcr.io/trexx/docker-static-sqlite3:latest` daily and uploads the results to the repository's Security tab.

## Releases

Releases are cut with the Release button: Actions → Release → Run workflow ([`.github/workflows/release.yml`](.github/workflows/release.yml), which calls `trexx/actions`' `release-image.yml`). Run it from the default branch.

1. It works out the tag from `SQLITE_VERSION` in the Dockerfile, turning the amalgamation id into the SQLite version: `3540100` becomes `3.54.1`. If that version was released before, it uses `<version>-N` for the rebuild (for example after a base image update). A tag can also be given by hand in the `tag` input.
2. It builds the image and pushes it as that tag and `latest`.
3. It creates the git tag and the GitHub release.

Ticking "dry run" only works out the tag and builds the image; nothing is pushed and no release is created. Old images are pruned from the package after a push (`latest` and the newest tagged images are kept).

Pushing a tag by hand (matching `*.*.*`) still works: [`.github/workflows/build.yml`](.github/workflows/build.yml) builds and pushes the image for that tag.
