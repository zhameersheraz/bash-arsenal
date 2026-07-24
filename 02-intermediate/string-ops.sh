#!/usr/bin/env bash
# string-ops.sh — common string operations in pure Bash.
#
# Usage: ./string-ops.sh
# Teaches: length, slicing, replace, trim, case conversion.

set -euo pipefail

s="Hello, World!"

echo "string:    $s"
echo "length:    ${#s}"              # 13

# Substring: ${var:offset:length}
echo "first 5:   ${s:0:5}"            # Hello
echo "from 7:    ${s:7}"              # World!
echo "last 6:    ${s: -6}"            # World!  (note the space before -)

# Replace first match
echo "${s/o/0}"                      # Hell0, World!

# Replace all matches
echo "${s//o/0}"                     # Hell0, W0rld!

# Delete from start (shortest match)
echo "${s#He*o}"                     # , World!  (greedy stops at first o)

# Delete from start (longest match)
echo "${s##He*o}"                    # rld!  (greedy goes to last o)

# Delete from end (shortest match)
echo "${s%,*!}"                      # Hello (trims from end)

# Delete from end (longest match)
echo "${s%%,*}   "                   # Hello

# Case conversion (Bash 4+)
lower="HELLO"
upper="hello"
echo "${lower,,}"                    # hello (lowercase)
echo "${upper^^}"                    # HELLO (uppercase)
echo "${lower,}"                     # hELLO (first char lower)
echo "${upper^}"                     # Hello (first char upper)

# Default values
unset var
echo "${var:-default}"               # default (var unchanged)
echo "${var:=default}"               # default (var now set to "default")

# Trim leading/trailing whitespace
trim() {
  local s="$1"
  # remove leading whitespace
  s="${s#"${s%%[![:space:]]*}"}"
  # remove trailing whitespace
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}
echo "trimmed: '$(trim "   spaced out   ")'"
