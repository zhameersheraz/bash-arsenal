#!/usr/bin/env bash
# traps.sh — handle signals and clean up properly.
#
# Usage: ./traps.sh
# Teaches: trap, signals, cleanup on Ctrl+C, temp file handling.

set -euo pipefail

# Create a temp file and a temp directory. The 'trap' makes sure they
# get cleaned up even if the user hits Ctrl+C.
TMPFILE=$(mktemp)
TMPDIR=$(mktemp -d)

cleanup() {
  local code=$?
  printf '\n[trap] cleaning up (exit code %d)...\n' "$code"
  rm -f "$TMPFILE"
  rm -rf "$TMPDIR"
  exit $code
}

# ERR fires on any command failure (with set -e)
on_err() {
  printf '[trap] error on line %s\n' "$LINENO" >&2
}

# EXIT fires when the script ends for ANY reason (success, failure, or signal)
trap cleanup EXIT
trap on_err ERR

# INT fires on Ctrl+C
trap 'printf "\n[trap] interrupted by user\n"; exit 130' INT

# TERM fires on kill <pid>
trap 'printf "\n[trap] terminated\n"; exit 143' TERM

echo "tmp file:  $TMPFILE"
echo "tmp dir:   $TMPDIR"
echo "pid:       $$"

# Write something to the temp file
echo "scratch data" > "$TMPFILE"
cat "$TMPFILE"

# A long-ish loop so you can hit Ctrl+C to test the INT trap
echo "running loop, press Ctrl+C to test (5s loop)..."
for i in 1 2 3 4 5; do
  echo "  tick $i"
  sleep 1
done

echo "loop finished normally"
# cleanup runs automatically via the EXIT trap
