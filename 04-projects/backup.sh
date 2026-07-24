#!/usr/bin/env bash
# backup.sh — tar.gz backups with rotation.
#
# Usage: ./backup.sh SOURCE DEST [NAME]
# Teaches: tar, date math, rotation, logging, locking.
#
# Keeps the last 7 daily backups. Older ones are deleted automatically.
# Safe to run from cron.

set -euo pipefail

SOURCE="${1:-}"
DEST="${2:-}"
NAME="${3:-$(basename "$SOURCE")}"

if [[ -z "$SOURCE" || -z "$DEST" ]]; then
  echo "Usage: $0 SOURCE DEST [NAME]"
  echo "  SOURCE  directory to back up"
  echo "  DEST    where to put the .tar.gz files"
  echo "  NAME    backup name (default: basename of SOURCE)"
  exit 1
fi

[[ -d "$SOURCE" ]] || { echo "Error: SOURCE not a directory: $SOURCE" >&2; exit 1; }
mkdir -p "$DEST"

LOG="$DEST/${NAME}.backup.log"
stamp=$(date +%Y%m%d-%H%M%S)
archive="$DEST/${NAME}-${stamp}.tar.gz"

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG"; }

# Prevent two backups running at the same time. mkdir is atomic on Linux.
LOCKDIR="$DEST/.${NAME}.lock"
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  log "ERROR: another backup is already running (lock: $LOCKDIR)"
  exit 1
fi
trap 'rm -rf "$LOCKDIR"' EXIT

log "starting backup: $SOURCE"
log "  archive: $archive"

# -c create, -z gzip, -f file, -p preserve perms
start=$(date +%s)
if tar -czpf "$archive" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")" 2>>"$LOG"; then
  size=$(du -h "$archive" | cut -f1)
  log "  done in $(( $(date +%s) - start ))s, size: $size"
else
  log "  FAILED"
  rm -f "$archive"
  exit 1
fi

# Rotate: keep only the 7 most recent backups
log "rotating old backups (keeping 7)..."
# List backups for this NAME, oldest first, skip the 7 newest, delete the rest
deleted=0
while IFS= read -r old; do
  rm -f "$old"
  ((deleted++))
  log "  deleted: $(basename "$old")"
done < <(ls -1tr "$DEST"/"${NAME}"-*.tar.gz 2>/dev/null | head -n -7)

log "summary: 1 created, $deleted deleted"
