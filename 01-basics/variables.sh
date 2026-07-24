#!/usr/bin/env bash
# variables.sh — how Bash variables work.
#
# Usage: ./variables.sh
# Teaches: assignment, expansion, readonly, command substitution.

# Assignment: NO spaces around the = sign.
name="zham"
count=42
pi=3.14159

# Use double quotes when expanding — protects against spaces and glob chars.
echo "Name: $name"
echo "Count: $count"
echo "Pi: $pi"

# Command substitution: $(command) runs the command and substitutes output.
today=$(date +%Y-%m-%d)
user=$(whoami)
echo "Today: $today"
echo "You are: $user"

# readonly makes a constant. You cannot reassign it.
readonly app_name="bash-arsenal"
echo "App: $app_name"

# Brace syntax ${var} is safer when concatenating with other text.
echo "${name}_dev"     # zham_dev
echo "$name_dev"       # empty — Bash looks for variable $name_dev

# Local variables inside functions (we'll cover functions later).
demo() {
  local inside="only visible in this function"
  echo "$inside"
}
demo

# Try this: change `name="zham"` to `name=zham` (no quotes, no spaces). Then
# try `name=zhameer sheraz` (with a space) — it'll error. That's why we
# quote on assignment when needed.
