#!/bin/bash

# Check if no argument was passed
if [ -z "$1" ]; then  # Length of argument is zero
  echo "No file argument given"
  exit 1
fi

# Check if argument is a regular file
if [ -f "$1" ]; then  # Is a regular file
  echo "$1 is a regular file."

# Check if argument is a directory
elif [ -d "$1" ]; then  # Is a directory
  echo "$1 is a directory."

# If it's neither a file nor a directory
else
  echo "$1 does not exist."
fi  # End of if block
