#!/bin/bash
# List files in current directory with actual size in KB using stat

printf "%-30s %10s\n" "Filename" "Size (KB)"
printf "%-30s %10s\n" "--------" "----------"

for file in *; do
  if [ -f "$file" ]; then
    size_bytes=$(stat c%s "$file")         # Get size in bytes
    size_kb=$(( (size_bytes + 1023) / 1024 )) # Round up to next KB
    printf "%-30s %10s\n" "$file" "$size_kb"
  fi
done
