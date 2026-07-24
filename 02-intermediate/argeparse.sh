#!/usr/bin/env bash
# argparse.sh — parse command-line flags and arguments.
#
# Usage: ./argparse.sh [-v] [-f FILE] [-n COUNT] name
# Teaches: getopts, while-shift, error handling, usage.

set -euo pipefail

verbose=0
file=""
count=1

usage() {
  cat <<EOF
Usage: $0 [-v] [-f FILE] [-n COUNT] NAME

Options:
  -v         verbose mode
  -f FILE    read input from FILE
  -n COUNT   number of times to greet (default: 1)
  -h         show this help
EOF
}

# getopts handles single-letter flags. Leading colon silences default
# error messages so we can handle them ourselves.
while getopts ":vf:n:h" opt; do
  case "$opt" in
    v) verbose=1 ;;
    f) file="$OPTARG" ;;
    n) count="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Error: -$OPTARG requires an argument" >&2; usage; exit 1 ;;
    \?) echo "Error: unknown flag -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

# Shift away the parsed options so $1 now refers to the first positional arg.
shift $((OPTIND - 1))

name="${1:-}"

if [[ -z "$name" ]]; then
  echo "Error: NAME is required" >&2
  usage
  exit 1
fi

if [[ -n "$file" && ! -f "$file" ]]; then
  echo "Error: file not found: $file" >&2
  exit 1
fi

[[ $verbose -eq 1 ]] && echo "[verbose] name=$name file=$file count=$count"

for ((i = 1; i <= count; i++)); do
  echo "Hello, $name! ($i/$count)"
done

if [[ -n "$file" ]]; then
  echo "--- contents of $file ---"
  cat "$file"
fi
