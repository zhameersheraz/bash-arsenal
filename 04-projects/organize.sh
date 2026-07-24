#!/usr/bin/env bash
# organize.sh — sort files in a directory into subfolders by extension.
#
# Usage: ./organize.sh [DIR]
# Teaches: find, mkdir, mv, dry-run, safety checks.
#
# A real-world "clean up my Downloads folder" script. Run it on a test
# directory first. Pass --dry-run to preview without moving anything.

set -euo pipefail

# Pretty output only on TTY
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; CYAN=$'\033[36m'; GREEN=$'\033[32m'; RESET=$'\033[0m'
else
  BOLD=""; DIM=""; CYAN=""; GREEN=""; RESET=""
fi

DRY_RUN=0
TARGET="."

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      echo "Usage: $0 [-n] [DIR]"
      echo "  -n, --dry-run   show what would be moved, don't move"
      echo "  DIR             target directory (default: current)"
      exit 0
      ;;
    -*) echo "Unknown flag: $1" >&2; exit 1 ;;
    *)  TARGET="$1"; shift ;;
  esac
done

# Resolve to absolute path and verify it exists
TARGET=$(realpath "$TARGET")
if [[ ! -d "$TARGET" ]]; then
  echo "Error: not a directory: $TARGET" >&2
  exit 1
fi

# Skip these (don't try to "organize" our own output folders)
SKIP_DIRS=("images" "documents" "archives" "code" "audio" "video" "other")

should_skip_dir() {
  local d="$1"
  for skip in "${SKIP_DIRS[@]}"; do
    [[ "$(basename "$d")" == "$skip" ]] && return 0
  done
  return 1
}

# Map extension -> folder
categorize() {
  local ext="${1,,}"   # lowercase
  case "$ext" in
    jpg|jpeg|png|gif|webp|svg|bmp|tiff) echo "images" ;;
    pdf|doc|docx|odt|txt|md|rtf|epub)   echo "documents" ;;
    zip|tar|gz|bz2|xz|7z|rar|iso)       echo "archives" ;;
    sh|py|js|ts|c|cpp|rs|go|java|html|css|json) echo "code" ;;
    mp3|flac|wav|ogg|m4a|aac)           echo "audio" ;;
    mp4|mkv|avi|mov|webm|flv)           echo "video" ;;
    *)                                  echo "other" ;;
  esac
}

mode_label() {
  if [[ $DRY_RUN -eq 1 ]]; then echo "[DRY-RUN]"; else echo "[MOVE]"; fi
}

echo "${BOLD}Organizing:${RESET} $TARGET  $(mode_label)"
echo

moved=0
skipped=0

# Find files one level deep, not in our output folders, not hidden
while IFS= read -r -d '' file; do
  dir=$(dirname "$file")
  if should_skip_dir "$dir"; then
    ((skipped++))
    continue
  fi

  # Skip hidden files and the script itself
  base=$(basename "$file")
  [[ "$base" == .* ]] && { ((skipped++)); continue; }
  [[ "$file" == "$0" ]] && { ((skipped++)); continue; }

  # No extension -> "other"
  if [[ "$base" != *.* ]]; then
    folder="other"
  else
    ext="${base##*.}"
    folder=$(categorize "$ext")
  fi

  dest_dir="$TARGET/$folder"
  dest_file="$dest_dir/$base"

  # Don't clobber — if file with same name exists in dest, append a number
  if [[ -e "$dest_file" ]]; then
    name="${base%.*}"
    ext_part="${base##*.}"
    [[ "$name" == "$ext_part" ]] && ext_part=""  # no-extension case
    n=1
    while [[ -e "$dest_dir/${name}_${n}${ext_part:+.$ext_part}" ]]; do
      ((n++))
    done
    if [[ -n "$ext_part" ]]; then
      dest_file="$dest_dir/${name}_${n}.${ext_part}"
    else
      dest_file="$dest_dir/${name}_${n}"
    fi
  fi

  printf "  %s %s -> %s/%s\n" "$(mode_label)" "$base" "$folder" "$(basename "$dest_file")"

  if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$dest_dir"
    mv "$file" "$dest_file"
  fi
  ((moved++))
done < <(find "$TARGET" -maxdepth 1 -type f -print0)

echo
printf "${GREEN}Done.${RESET} %d moved, %d skipped\n" "$moved" "$skipped"

if [[ $DRY_RUN -eq 1 ]]; then
  printf "${DIM}Re-run without --dry-run to actually move files.${RESET}\n"
fi
