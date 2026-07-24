# Bash Cheatsheet

A one-page reference. Keep it open in a tab.

## Running

```bash
chmod +x script.sh       # make executable
./script.sh              # run from current dir
bash script.sh           # run without chmod
bash -n script.sh        # syntax check, don't run
bash -x script.sh        # trace, print every command
```

## Variables

```bash
name="zham"              # no spaces around =
echo "$name"             # "zham"
echo "${name}_dev"       # "zham_dev" — braces for safety
readonly PI=3.14         # constant
```

## Input

```bash
read -p "Name: " name
read -s -p "Pass: " pass  # silent (passwords)
```

## Conditions

```bash
if [[ -f "$file" ]]; then echo "exists"; fi
if [[ "$a" == "$b" ]]; then echo "match"; fi
if [[ "$n" -gt 10 ]]; then echo "big"; fi
```

## Loops

```bash
for i in 1 2 3; do echo "$i"; done
for f in *.txt; do echo "$f"; done
while read -r line; do echo "$line"; done < file.txt
```

## Functions

```bash
greet() {
  local name="$1"
  echo "Hi $name"
}
greet "zham"
```

## Arrays

```bash
arr=(a b c)
echo "${arr[0]}"         # a
echo "${arr[@]}"         # all
echo "${#arr[@]}"        # count
arr+=(d)                 # append
```

## Useful flags

```bash
set -euo pipefail        # exit on error, undefined var, pipe fail
set -x                   # debug: print each command
```

## File tests

```bash
[[ -f f ]]  # is file
[[ -d d ]]  # is dir
[[ -e p ]]  # exists
[[ -r f ]]  # readable
[[ -s f ]]  # exists and not empty
```

## Common gotchas

- Always quote variables: `"$var"`, never bare `$var`
- Use `[[ ]]` not `[ ]` (safer, no word splitting)
- Use `$(cmd)` not backticks (nestable, clearer)
- Use `read -r` (raw, no backslash escapes)
