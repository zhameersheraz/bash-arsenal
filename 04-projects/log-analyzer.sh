#!/usr/bin/env bash
# log-analyzer.sh — quick stats from an SSH/auth log file.
#
# Usage: ./log-analyzer.sh [LOG_FILE]
# Teaches: grep, awk, sort, uniq -c, date filtering.
#
# Default: /var/log/auth.log (Debian/Kali). Falls back to /var/log/secure.

set -euo pipefail

LOG="${1:-}"
if [[ -z "$LOG" ]]; then
  for candidate in /var/log/auth.log /var/log/secure /var/log/messages; do
    if [[ -r "$candidate" ]]; then
      LOG="$candidate"
      break
    fi
  done
fi

if [[ -z "$LOG" || ! -r "$LOG" ]]; then
  echo "Error: no readable log file. Pass one as argument." >&2
  exit 1
fi

# Colors on TTY
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; CYAN=$'\033[36m'; RED=$'\033[31m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
  BOLD=""; CYAN=""; RED=""; DIM=""; RESET=""
fi

heading() { printf "\n%s%s%s\n" "$BOLD" "$1" "$RESET"; printf -- '-%.0s' {1..40}; printf '\n'; }

heading "Log: $LOG"
echo "  size:   $(du -h "$LOG" | cut -f1)"
echo "  lines:  $(wc -l < "$LOG")"

heading "Failed login attempts (top 10 source IPs)"
grep -i "failed password" "$LOG" \
  | grep -oE 'from [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' \
  | awk '{print $2}' \
  | sort | uniq -c | sort -rn | head -10 \
  | awk '{printf "  %-20s %s\n", $2, $1" attempts"}'

heading "Failed login attempts (top 10 usernames)"
grep -i "failed password" "$LOG" \
  | grep -oE 'for (invalid user )?[a-zA-Z0-9_-]+' \
  | awk '{print $2}' \
  | sort | uniq -c | sort -rn | head -10 \
  | awk '{printf "  %-20s %s\n", $2, $1" attempts"}'

heading "Successful logins (last 10)"
grep -i "accepted " "$LOG" \
  | tail -10 \
  | awk '{for(i=1;i<=NF;i++) if($i=="from") print "  " $(i+1)}' \
  | head -10

heading "sudo invocations (top 10 users)"
grep -i "sudo:" "$LOG" \
  | grep -oE 'sudo:[[:space:]]+[a-zA-Z0-9_-]+' \
  | awk '{print $2}' \
  | sort | uniq -c | sort -rn | head -10 \
  | awk '{printf "  %-20s %s\n", $2, $1" times"}'

heading "Summary"
total_failed=$(grep -ci "failed password" "$LOG" || true)
total_accepted=$(grep -ci "accepted " "$LOG" || true)
echo "  Total failed:   $total_failed"
echo "  Total accepted: $total_accepted"

# Highlight anything that looks like a brute-force source
heavy=$(grep -i "failed password" "$LOG" \
  | grep -oE 'from [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' \
  | awk '{print $2}' | sort | uniq -c | sort -rn | head -1 | awk '{print $1}')
if [[ -n "$heavy" && "$heavy" -gt 50 ]]; then
  printf "\n%s⚠  Warning:%s top source has %d failures — possible brute force\n" "$RED" "$RESET" "$heavy"
fi
