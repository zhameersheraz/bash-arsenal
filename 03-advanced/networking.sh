#!/usr/bin/env bash
# networking.sh — common networking tasks in Bash.
#
# Usage: ./networking.sh [host]
# Teaches: /dev/tcp, nc, curl, ping, DNS lookups, port checks.

set -euo pipefail

target="${1:-example.com}"

# 1) /dev/tcp is a Bash built-in. No nc needed for simple checks.
#    Opening the path opens a TCP connection. Bash returns failure
#    if the connection can't be established.
echo "--- TCP port check via /dev/tcp ---"
port=80
if timeout 3 bash -c "echo > /dev/tcp/$target/$port" 2>/dev/null; then
  echo "  $target:$port is open"
else
  echo "  $target:$port is closed or filtered"
fi

# 2) DNS lookup
echo "--- DNS ---"
ip=$(getent hosts "$target" | awk '{print $1}' | head -1)
echo "  $target -> $ip"

# 3) HTTP request with curl
echo "--- HTTP HEAD ---"
if command -v curl > /dev/null; then
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://$target" || echo "fail")
  echo "  https://$target -> HTTP $http_code"
fi

# 4) Ping (may be blocked)
echo "--- ping (3 packets) ---"
if ping -c 3 -W 2 "$target" 2>/dev/null; then
  echo "  host responds to ping"
else
  echo "  ping blocked or host down (common in cloud environments)"
fi

# 5) My local network info
echo "--- local network ---"
echo "  hostname:  $(hostname)"
echo "  ip:        $(hostname -I | awk '{print $1}')"
echo "  gateway:   $(ip route | awk '/default/ {print $3}')"
echo "  dns:       $(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ')"

# 6) Quick port range scan with /dev/tcp
echo "--- scan common ports on $target ---"
for port in 22 80 443 8080 3306 5432; do
  if timeout 1 bash -c "echo > /dev/tcp/$target/$port" 2>/dev/null; then
    echo "  $port OPEN"
  fi
done
