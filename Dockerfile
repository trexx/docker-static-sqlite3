FROM alpine:latest@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c AS build

ENV SQLITE_VERSION="3460000"
ADD https://www.sqlite.org/2024/sqlite-amalgamation-${SQLITE_VERSION}.zip /tmp

RUN apk add --no-cache gcc libarchive-tools musl-dev

RUN mkdir /tmp/src && \
  bsdtar xvf /tmp/sqlite-amalgamation-${SQLITE_VERSION}.zip --strip-components=1 -C /tmp/src

WORKDIR /tmp/src

RUN gcc -O2                                   \
  -DSQLITE_DQS=0                              \
  -DSQLITE_USE_ALLOCA                         \
  -DSQLITE_THREADSAFE=0                       \
  -DSQLITE_LIKE_DOESNT_MATCH_BLOBS            \
  -DSQLITE_OMIT_AUTOINCREMENT                 \
  -DSQLITE_OMIT_AUTOINIT                      \
  -DSQLITE_OMIT_AUTOMATIC_INDEX               \
  -DSQLITE_OMIT_AUTORESET                     \
  -DSQLITE_OMIT_AUTOVACUUM                    \
  -DSQLITE_OMIT_BETWEEN_OPTIMIZATION          \
  -DSQLITE_OMIT_BLOB_LITERAL                  \
  -DSQLITE_OMIT_CASE_SENSITIVE_LIKE_PRAGMA    \
  -DSQLITE_OMIT_CAST                          \
  -DSQLITE_OMIT_CHECK                         \
  -DSQLITE_OMIT_COMPILEOPTION_DIAGS           \
  -DSQLITE_OMIT_COMPOUND_SELECT               \
  -DSQLITE_OMIT_DATETIME_FUNCS                \
  -DSQLITE_OMIT_DECLTYPE                      \
  -DSQLITE_OMIT_DEPRECATED                    \
  -DSQLITE_OMIT_DESERIALIZE                   \
  -DSQLITE_OMIT_EXPLAIN                       \
  -DSQLITE_OMIT_FLAG_PRAGMAS                  \
  -DSQLITE_OMIT_FOREIGN_KEY                   \
  -DSQLITE_OMIT_GENERATED_COLUMNS             \
  -DSQLITE_OMIT_GET_TABLE                     \
  -DSQLITE_OMIT_HEX_INTEGER                   \
  -DSQLITE_OMIT_INCRBLOB                      \
  -DSQLITE_OMIT_INTEGRITY_CHECK               \
  -DSQLITE_OMIT_INTROSPECTION_PRAGMAS         \
  -DSQLITE_OMIT_JSON                          \
  -DSQLITE_OMIT_LIKE_OPTIMIZATION             \
  -DSQLITE_OMIT_LOAD_EXTENSION                \
  -DSQLITE_OMIT_LOCALTIME                     \
  -DSQLITE_OMIT_LOOKASIDE                     \
  -DSQLITE_OMIT_MEMORYDB                      \
  -DSQLITE_OMIT_OR_OPTIMIZATION               \
  -DSQLITE_OMIT_PROGRESS_CALLBACK             \
  -DSQLITE_OMIT_QUICKBALANCE                  \
  -DSQLITE_OMIT_SCHEMA_PRAGMAS                \
  -DSQLITE_OMIT_SCHEMA_VERSION_PRAGMAS        \
  -DSQLITE_OMIT_SHARED_CACHE                  \
  -DSQLITE_OMIT_SEH                           \
  -DSQLITE_OMIT_TCL_VARIABLE                  \
  -DSQLITE_OMIT_TEMPDB                        \
  -DSQLITE_OMIT_TRACE                         \
  -DSQLITE_OMIT_TRUNCATE_OPTIMIZATION         \
  -DSQLITE_OMIT_UTF16                         \
  -DSQLITE_OMIT_XFER_OPT                      \
  -DSQLITE_UNTESTABLE                         \
  shell.c sqlite3.c -static -lm -o sqlite3

RUN strip --strip-all sqlite3

FROM scratch
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-static-sqlite3"

COPY --from=build /tmp/src/sqlite3 /sqlite3 