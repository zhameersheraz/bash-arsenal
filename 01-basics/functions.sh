#!/usr/bin/env bash
# functions.sh — defining and calling functions.
#
# Usage: ./functions.sh
# Teaches: function syntax, arguments, return values, local variables.

# Two ways to define a function (they're identical):
greet() {
  echo "Hi, $1!"
}

# or
# function greet { ... }  # Bash-specific, less portable. Skip it.

greet "zham"

# Multiple arguments
add() {
  local a="$1"
  local b="$2"
  echo $((a + b))     # echo the result
}

result=$(add 3 4)
echo "3 + 4 = $result"

# Functions can return an exit code (0-255) with `return`.
is_even() {
  local n="$1"
  if (( n % 2 == 0 )); then
    return 0   # true
  else
    return 1   # false
  fi
}

if is_even 42; then
  echo "42 is even"
fi

# `local` is critical. Without it, variables leak into the global scope
# and can clobber other things. Always use local inside functions.
