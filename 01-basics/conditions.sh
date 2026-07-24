#!/usr/bin/env bash
# conditions.sh — if/elif/else and test operators.
#
# Usage: ./conditions.sh
# Teaches: [[ ]], integer and string comparisons, file tests.

# [[ ]] is the modern test syntax. Safer than [ ] because it doesn't
# word-split or glob-expand inside.

n=15

if [[ $n -lt 10 ]]; then
  echo "small"
elif [[ $n -lt 20 ]]; then
  echo "medium"
else
  echo "big"
fi

# String comparisons
a="hello"
b="world"
if [[ "$a" == "$b" ]]; then
  echo "match"
else
  echo "no match"
fi

# File tests
file="/etc/passwd"
if [[ -f "$file" && -r "$file" ]]; then
  echo "$file exists and is readable"
fi

# Common operators:
#   -f file  is regular file
#   -d dir   is directory
#   -e path  exists
#   -z str   string is empty
#   -n str   string is non-empty
#   -eq, -ne, -lt, -gt, -le, -ge  integer comparison
#   ==, !=   string equality
#   =~       regex match
#   !        logical NOT

# Regex match example
email="zham@example.com"
if [[ "$email" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]; then
  echo "looks like an email"
fi
