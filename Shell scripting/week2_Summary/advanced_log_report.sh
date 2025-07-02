#!/bin/bash

# ===============================
# Advanced Automated Log Report Generator
# ===============================

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# === Variables ===
LOG_DIR=""
KEYWORDS=()
REPORT_FORMAT="txt"
REPORT_FILE=""
RECURSIVE=false
START_TIME=""
END_TIME=""
ELAPSED_TIME=""

# === HELP ===
print_help() {
  echo -e "${GREEN}Usage:${NC} ./advanced_log_report.sh [log_directory] --keywords KEY1 KEY2 ... [--format txt|csv] [--recursive]"
  echo "Options:"
  echo "  --keywords     Space-separated list of keywords (e.g., ERROR WARNING)"
  echo "  --format       Report output format: txt (default) or csv"
  echo "  --recursive    Scan subdirectories"
  echo "  --help         Show help"
  exit 0
}

# === Arguments Parsing ===
parse_args() {
  LOG_DIR="$1"
  shift # Remove the first argument (log directory)

  while [[ $# -gt 0 ]]; do  # when there are still arguments
    case "$1" in  
      --keywords) 
        shift
        while [[ $# -gt 0 && $1 != --* ]]; do
          KEYWORDS+=("$1")
          shift
        done
        ;;
      --format)
        shift
        if [[ "$1" == "csv" || "$1" == "txt" ]]; then
          REPORT_FORMAT="$1"
          shift
        else
          echo -e "${RED}Error: Invalid format${NC}"
          exit 1
        fi
        ;;
      --recursive)
        RECURSIVE=true
        shift
        ;;
      --help)
        print_help
        ;;
      *)
        echo -e "${RED}Unknown argument: $1${NC}"
        exit 1
        ;;
    esac
  done
}

# === Validate Input ===
validate_input() {
  if [[ -z "$LOG_DIR" || ! -d "$LOG_DIR" ]]; then
    echo -e "${RED}Invalid or missing directory${NC}"
    exit 1
  fi

  if [[ ${#KEYWORDS[@]} -eq 0 ]]; then
    echo -e "${RED}No keywords provided${NC}"
    exit 1
  fi
  REPORT_FILE="report.${REPORT_FORMAT}"
}

# === Count Keywords ===
count_keywords() {
  local file="$1"
  local filename
  filename=$(basename "$file")

  if [[ "$REPORT_FORMAT" == "txt" ]]; then
    echo "" >> "$REPORT_FILE"
    echo "Log File: $filename" >> "$REPORT_FILE"
    printf "| %-10s | %-11s |\n" "Keyword" "Occurrences" >> "$REPORT_FILE"
    printf "|------------|-------------|\n" >> "$REPORT_FILE"
  fi

  for keyword in "${KEYWORDS[@]}"; do
    count=$(grep -o "$keyword" "$file" | wc -l)
    if [[ "$REPORT_FORMAT" == "txt" ]]; then
      printf "| %-10s | %-11d |\n" "$keyword" "$count" >> "$REPORT_FILE"
    else
      echo "$filename,$keyword,$count" >> "$REPORT_FILE"
    fi
  done
}

# === Generate Report ===
generate_report() {
  [[ "$REPORT_FORMAT" == "txt" ]] && {
    echo "Advanced Log Report" > "$REPORT_FILE"
    echo "===================" >> "$REPORT_FILE"
  } || echo "File,Keyword,Occurrences" > "$REPORT_FILE"

  if $RECURSIVE; then
    mapfile -t files < <(find "$LOG_DIR" -type f -name "*.log")
  else
    mapfile -t files < <(find "$LOG_DIR" -maxdepth 1 -type f -name "*.log")
  fi

  for file in "${files[@]}"; do
    [[ -f "$file" ]] && count_keywords "$file"
  done
}

# === Measure Time ===
measure_time() {
  START_TIME=$(date +%s.%N)

  parse_args "$@"
  validate_input
  generate_report

  END_TIME=$(date +%s.%N)
  ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc)

  [[ "$REPORT_FORMAT" == "txt" ]] && {
    echo "" >> "$REPORT_FILE"
    echo "Total Execution Time: ${ELAPSED_TIME} seconds" >> "$REPORT_FILE"
  }
}

# === MAIN ===
main() {
  measure_time "$@"
  echo -e "${GREEN} Directory: $LOG_DIR${NC}"
  echo -e "${GREEN} Keywords: ${KEYWORDS[*]}${NC}"
  echo -e "${GREEN} Format: $REPORT_FORMAT${NC}"
  [[ "$RECURSIVE" == true ]] && echo -e "${GREEN}Recursive: ON${NC}"
  echo -e "${GREEN} Report saved to: $REPORT_FILE${NC}"
  echo -e "${GREEN} Execution Time: ${ELAPSED_TIME} seconds${NC}"
}

main "$@"
