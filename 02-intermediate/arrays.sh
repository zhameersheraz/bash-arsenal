#!/usr/bin/env bash
# arrays.sh — how Bash arrays work.
#
# Usage: ./arrays.sh
# Teaches: indexed arrays, iteration, length, slicing.

set -euo pipefail

# Two ways to create an array:
fruits=(apple banana cherry)
# or
declare -a colors=("red" "green" "blue")

# Access by index (0-based)
echo "first: ${fruits[0]}"        # apple
echo "third: ${fruits[2]}"        # cherry

# All elements: ${arr[@]}
echo "all fruits: ${fruits[@]}"

# Number of elements
echo "count: ${#fruits[@]}"

# Last element trick
echo "last: ${fruits[-1]}"        # cherry (Bash 4.3+)

# Append
fruits+=("date")
echo "after append: ${fruits[@]}"

# Slice (offset length)
echo "slice 1-2: ${fruits[@]:1:2}"  # banana cherry

# Iterate
echo "--- iterating ---"
for fruit in "${fruits[@]}"; do
  echo "  fruit: $fruit"
done

# Iterate with index
echo "--- with index ---"
for i in "${!fruits[@]}"; do
  echo "  $i: ${fruits[$i]}"
done

# Arrays from command output
echo "--- files in current dir ---"
files=(*.sh)
echo "found ${#files[@]} .sh files"
for f in "${files[@]}"; do
  echo "  $f"
done
