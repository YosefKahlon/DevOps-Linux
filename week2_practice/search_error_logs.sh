#!/bin/bash
# This script finds and prints all lines with "ERROR" in access.log and counts total occurrences.

log_file="access.log"

if [ ! -f "$log_file" ]; then
  echo "File $log_file not found!"
  exit 1
fi

echo "Lines containing 'ERROR':"
grep "ERROR" "$log_file"

echo
count=$(grep -o "ERROR" "$log_file" | wc -l)
echo "Total 'ERROR' occurrences: $count"
