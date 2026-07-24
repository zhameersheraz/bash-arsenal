#!/usr/bin/env bash
# error-handling.sh — making Bash scripts fail loud and clean.
#
# Usage: ./error-handling.sh
# Teaches: set flags, ||, &&, exit codes, logging to stderr.

# These three flags are the gold standard for serious scripts:
#   -e  exit immediately if any command fails
#   -u  error on unset variables (catches typos)
#   -o pipefail  a pipe fails if ANY command in it fails, not just the last
set -euo pipefail

# Red text for errors, only on a TTY
if [[ -t 2 ]]; then
  RED=$'\033[31m'; RESET=$'\033[0m'
else
  RED=""; RESET=""
fi

log_info()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
log_error() { printf '%s[ERROR]%s %s\n' "$RED" "$RESET" "$*" >&2; }

die() {
  log_error "$*"
  exit 1
}

# 1) && runs the second command only if the first succeeded
log_info "step 1: making /tmp/test-dir"
mkdir -p /tmp/test-dir && log_info "  ok"

# 2) || runs the second command only if the first failed
log_info "step 2: reading a file that may not exist"
cat /tmp/does-not-exist 2>/dev/null || log_info "  file missing, continuing"

# 3) explicit check with die
file="/etc/hostname"
if [[ ! -r "$file" ]]; then
  die "$file is not readable"
fi
log_info "step 3: read $file ok"

# 4) pipefail in action: this should fail because the first command fails
log_info "step 4: pipefail demo"
if false | true; then
  log_info "  pipe succeeded (pipefail NOT set)"
else
  log_info "  pipe failed as expected (pipefail IS set)"
fi

# 5) catching errors without exiting
log_info "step 5: try/except style"
if ! grep "root" /etc/passwd > /dev/null; then
  log_info "  no root user (weird!)"
else
  log_info "  found root user"
fi

# 6) custom EXIT trap to log final status
on_exit() {
  local code=$?
  if [[ $code -eq 0 ]]; then
    log_info "script finished cleanly"
  else
    log_error "script failed with exit code $code"
  fi
}
trap on_exit EXIT

# clean up
rm -rf /tmp/test-dir
