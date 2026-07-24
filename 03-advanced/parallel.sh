#!/usr/bin/env bash
# parallel.sh — running multiple things at once.
#
# Usage: ./parallel.sh
# Teaches: background jobs, wait, xargs -P, GNU parallel.

set -euo pipefail

# 1) Background jobs with & and wait
echo "--- background + wait ---"
start=$(date +%s)
for i in 1 2 3 4 5; do
  sleep 1 &
done
wait                                          # wait for ALL background jobs
end=$(date +%s)
echo "  5 sleeps ran in $((end - start))s (parallel)"

# 2) Sequential comparison
start=$(date +%s)
for i in 1 2 3 4 5; do
  sleep 1
done
end=$(date +%s)
echo "  5 sleeps ran in $((end - start))s (sequential)"

# 3) xargs -P (run N commands in parallel)
echo "--- xargs -P ---"
if command -v xargs > /dev/null; then
  start=$(date +%s)
  printf '%s\n' 1 2 3 4 5 6 7 8 | xargs -n 1 -P 4 -I{} sh -c 'sleep 1; echo "done {}"'
  end=$(date +%s)
  echo "  8 sleeps ran in $((end - start))s with -P 4"
fi

# 4) GNU parallel if installed
echo "--- GNU parallel ---"
if command -v parallel > /dev/null; then
  parallel -j 4 'echo "task {}" && sleep 1' ::: a b c d e f g h
else
  echo "  parallel not installed (apt install parallel)"
fi

# 5) Capture PIDs explicitly
echo "--- explicit pids ---"
pids=()
for i in 1 2 3; do
  ( sleep 1; echo "  task $i done" ) &
  pids+=($!)
done
echo "  started pids: ${pids[*]}"
for pid in "${pids[@]}"; do
  wait "$pid"
done
echo "  all done"
