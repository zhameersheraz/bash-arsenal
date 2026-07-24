#!/usr/bin/env bash
# port-scanner.sh — fast TCP port scanner using /dev/tcp.
#
# Usage: ./port-scanner.sh HOST [START_PORT-END_PORT]
#        ./port-scanner.sh 192.168.1.1
#        ./port-scanner.sh 192.168.1.1 1-1024
#        ./port-scanner.sh scanme.nmap.org 20-100
# Teaches: /dev/tcp, parallel scanning, service-name lookups.
#
# Uses background jobs to scan many ports at once. No nmap required.

set -euo pipefail

HOST="${1:-}"
RANGE="${2:-1-1024}"

if [[ -z "$HOST" ]]; then
  echo "Usage: $0 HOST [START-END]"
  exit 1
fi

start_port="${RANGE%-*}"
end_port="${RANGE#*-}"

if ! [[ "$start_port" =~ ^[0-9]+$ && "$end_port" =~ ^[0-9]+$ ]]; then
  echo "Error: bad port range. Use START-END, e.g. 1-1024" >&2
  exit 1
fi

# Resolve hostname to IP (also checks the host exists)
if ! ip=$(getent hosts "$HOST" | awk '{print $1}' | head -1); then
  echo "Error: cannot resolve $HOST" >&2
  exit 1
fi
# strip IPv6 if present
ip="${ip%% *}"

echo "Scanning $HOST ($ip), ports $start_port-$end_port"
echo

scan_port() {
  local port=$1
  if timeout 1 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null; then
    # Try to map to a service name
    local service
    service=$(getent services "$port" | awk '{print $1}' | head -1)
    [[ -z "$service" ]] && service="unknown"
    printf "  %-5d OPEN   %s\n" "$port" "$service"
  fi
}

# Run scans in batches of 100 parallel jobs
batch_size=100
for ((p = start_port; p <= end_port; p++)); do
  scan_port "$p" &
  # If we have $batch_size jobs running, wait for them
  if (( (p - start_port + 1) % batch_size == 0 )); then
    wait
  fi
done
wait   # catch the last batch

echo
echo "done."
