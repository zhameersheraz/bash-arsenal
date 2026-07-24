#!/usr/bin/env bash
# hello.sh — your first Bash script.
#
# Usage: ./hello.sh [name]
# Teaches: shebang, variables, arguments, exit codes.

# The first line is called a "shebang". It tells the OS which interpreter
# to use. /usr/bin/env bash is more portable than /bin/bash.

# $1 is the first argument passed to the script.
# ${1:-world} means "use $1, or 'world' if $1 is empty".
name="${1:-world}"

echo "Hello, $name!"
echo "You passed $# argument(s)."
echo "I am PID $$, running on $HOSTNAME."

# Exit 0 means success. Anything non-zero is an error.
exit 0
