#!/usr/bin/env bash
# case.sh — pattern matching with case statements.
#
# Usage: ./case.sh [start|stop|restart|status]
# Teaches: case, glob patterns, default case.

set -euo pipefail

action="${1:-}"

case "$action" in
  start)
    echo "Starting service..."
    ;;
  stop)
    echo "Stopping service..."
    ;;
  restart|reload)        # multiple patterns, one branch
    echo "Restarting service..."
    ;;
  status)
    echo "Service is running"
    ;;
  "")                    # empty string = no argument
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
  *)
    echo "Unknown action: $action"
    echo "Valid actions: start, stop, restart, status"
    exit 1
    ;;
esac

# Glob patterns inside case are powerful:
#   *.txt      matches any .txt file
#   /home/*    matches anything under /home
#   [Yy]es     matches Yes or yes
#   ????       matches any 4-char string
#   *)         default / catch-all
