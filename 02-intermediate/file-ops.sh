#!/usr/bin/env bash
# file-ops.sh — common file operations in Bash.
#
# Usage: ./file-ops.sh
# Teaches: read/write files, line counts, find, safe iteration.

set -euo pipefail

# Create a sample file to play with
sample="/tmp/bash-arsenal-sample.txt"
cat > "$sample" <<'EOF'
apple
banana
cherry
date
elderberry
EOF

echo "--- file exists? ---"
[[ -f "$sample" ]] && echo "yes, size=$(stat -c%s "$sample") bytes"

echo "--- line count, word count, char count ---"
wc "$sample"

echo "--- read line by line ---"
while IFS= read -r line; do
  echo "  line: $line"
done < "$sample"

echo "--- read into array ---"
mapfile -t lines < "$sample"
echo "first line: ${lines[0]}"
echo "last line:  ${lines[-1]}"

echo "--- write to file (overwrite) ---"
out="/tmp/bash-arsenal-out.txt"
echo "new content" > "$out"

echo "--- append ---"
echo "more content" >> "$out"
echo "even more" >> "$out"

echo "--- here-document (multi-line write) ---"
report="/tmp/bash-arsenal-report.txt"
cat > "$report" <<EOF
Report generated: $(date)
Sample file:      $sample
Lines in sample:  ${#lines[@]}
Hostname:         $(hostname)
EOF
cat "$report"

echo "--- find files (recursive) ---"
find . -maxdepth 2 -name "*.sh" -type f | head -10

echo "--- safe cleanup ---"
rm -f "$sample" "$out" "$report"
echo "cleaned up"
