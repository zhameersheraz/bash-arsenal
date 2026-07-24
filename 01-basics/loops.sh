#!/usr/bin/env bash
# loops.sh — for, while, until.
#
# Usage: ./loops.sh
# Teaches: C-style and list-style for, while read, break/continue.

# 1) List-style for loop
echo "--- numbers 1-5 ---"
for i in 1 2 3 4 5; do
  echo "i = $i"
done

# 2) Range-style (Bash 3+)
echo "--- 1 to 5 with range ---"
for i in {1..5}; do
  echo "i = $i"
done

# 3) C-style for loop
echo "--- 0 to 9 step 2 ---"
for ((i = 0; i < 10; i += 2)); do
  echo "i = $i"
done

# 4) Iterate over files
echo "--- .sh files in current dir ---"
for f in *.sh; do
  echo "found: $f"
done

# 5) while loop
echo "--- countdown from 5 ---"
count=5
while [[ $count -gt 0 ]]; do
  echo "$count"
  ((count--))
done
echo "blast off!"

# 6) until loop (runs until condition is true)
echo "--- until counter hits 3 ---"
counter=0
until [[ $counter -eq 3 ]]; do
  echo "counter: $counter"
  ((counter++))
done

# 7) Reading a file line by line
echo "--- /etc/hostname line by line ---"
while IFS= read -r line; do
  echo "line: $line"
done < /etc/hostname

# break and continue work the same as in C.
