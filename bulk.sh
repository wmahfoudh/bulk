#!/bin/bash
# bulk.sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 \"...(scope=pattern)...(out=folder)...(ext=extenstion)...\""
  exit 1
fi

cmd_str="$1"

# Extract parameters (no spaces after the '=' are assumed)
scope=$(echo "$cmd_str" | sed -n 's/.*(scope=\([^)]*\)).*/\1/p')
out=$(echo "$cmd_str" | sed -n 's/.*(out=\([^)]*\)).*/\1/p')
ext=$(echo "$cmd_str" | sed -n 's/.*(ext=\([^)]*\)).*/\1/p')

# Ensure scope is provided.
if [ -z "$scope" ]; then
  echo "Error: The command string must include a (scope=pattern) parameter."
  exit 1
fi

# Default to current directory if out is empty.
if [ -z "$out" ]; then
  out="."
fi

# Default extension to 'txt' if ext is empty.
if [ -z "$ext" ]; then
  ext="txt"
fi

# Prepare the command template:
# Replace the (scope=...) part with a placeholder __FILE__
cmd_template=$(echo "$cmd_str" | sed -e 's/(scope=[^)]*)/__FILE__/')

# Replace the destination part.
# Using extended regex (-E) to match an optional preceding slash,
# then literal (out=...) followed by an optional slash and literal (ext=...)
cmd_template=$(echo "$cmd_template" | sed -E 's#/?\(out=[^)]*\)/?\(ext=[^)]*\)#__OUTFILE__#')

# Create the output folder if it doesn't exist.
mkdir -p "$out"

# Loop over all files matching the scope pattern.
for file in $scope; do
  [ -e "$file" ] || continue

  # Get the base filename (without its extension).
  base=$(basename "$file")
  base="${base%.*}"

  # Construct the output file path.
  out_file="$out/$base.$ext"

  # Replace tokens with quoted filenames to handle spaces.
  cmd_to_run="${cmd_template//__FILE__/\"$file\"}"
  cmd_to_run="${cmd_to_run//__OUTFILE__/\"$out_file\"}"

  echo "Running: $cmd_to_run"
  eval "$cmd_to_run"
done
