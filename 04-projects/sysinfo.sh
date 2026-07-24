#!/usr/bin/env bash
# sysinfo.sh — print a quick summary of this machine.
#
# Usage: ./sysinfo.sh
# Teaches: command substitution, here-strings, basic formatting.

# Fail fast on errors and unset variables.
set -euo pipefail

# --- Colors (auto-disabled if not a TTY) ---
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  CYAN=$'\033[36m'
  RESET=$'\033[0m'
else
  BOLD=""; DIM=""; CYAN=""; RESET=""
fi

# --- Helpers ---
section() {
  printf "\n%s%s%s\n" "$BOLD" "$1" "$RESET"
  printf '%s\n' "----------------------------------------"
}

kv() {
  # key value, padded for alignment
  printf "  %-14s %s\n" "$1:" "$2"
}

# --- Sections ---
section "System"
kv "Hostname"   "$(hostname)"
kv "OS"         "$(uname -srm)"
kv "Kernel"     "$(uname -r)"
kv "Uptime"     "$(uptime -p 2>/dev/null || uptime)"
kv "Shell"      "$SHELL"
kv "User"       "$(whoami)"

section "Hardware"
kv "CPU"        "$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
kv "Cores"      "$(nproc)"
kv "Memory"     "$(free -h | awk '/^Mem:/ {print $3 " used / " $2 " total"}')"
kv "Disk /"     "$(df -h / | awk 'NR==2 {print $3 " used / " $2 " total (" $5 " full)"}')"

section "Network"
# Pick the first non-loopback IPv4 address.
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
[[ -z "$ip" ]] && ip="(no network)"
kv "IP"         "$ip"
kv "Interfaces" "$(ls /sys/class/net | tr '\n' ' ')"

section "Top processes"
ps -eo pid,pcpu,pmem,comm --sort=-pcpu | head -6

printf "\n%sDone.%s\n" "$DIM" "$RESET"
