#!/usr/bin/env bash

set -eu

sqlite3 "${DATA_DIR}/db.sqlite3" ".backup '${BACKUP_DIR}/db.sqlite3'"
rsync -avu --delete --exclude={'db.*','icon_cache','tmp'} "${DATA_DIR}/" "${BACKUP_DIR}"
