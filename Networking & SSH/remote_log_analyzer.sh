#!/bin/bash

# ======================
# Remote Log Analyzer
# ======================
print_help() {
  echo "Remote Log Analyzer"
  echo "========================="
  echo "This script connects to a remote Linux VM via SSH,"
  echo "downloads log files (including ZIP/TAR archives),"
  echo "searches for specified keywords, and generates summary reports."
  echo
  echo "Usage:"
  echo "  $0 <user@host> <remote_log_directory> <keyword1> [keyword2] ..."
  echo
  echo "Example:"
  echo "  $0 yosef@20.73.71.39 /var/log/ ERROR WARNING CRITICAL"
  echo
  echo "Output Files:"
  echo "  - remote_report.txt : Human-readable aligned summary"
  echo "  - remote_report.csv : CSV file for Excel"
  echo
  echo "Features:"
  echo "  - SSH key authentication only (no password prompts)"
  echo "  - Auto extraction of .zip, .tar, .tar.gz"
  echo "  - Keyword counting per file"
  echo "  - Total keyword summary"
  echo "  - Color-coded terminal output"
  echo
  echo "Tip:"
  echo "  Make sure your SSH key is set up via ssh-copy-id before running."
  echo
}


# ======================
# Step 1: Parse Arguments
# ======================
parse_args() {
  if [[ "$1" == "--help" || "$#" -lt 3 ]]; then
    print_help
    exit 1
  fi
  REMOTE="$1"
  REMOTE_DIR="$2"
  shift 2
  KEYWORDS=("$@") # Store all remaining arguments as keywords 
}

# ======================
# Step 2: Check SSH Connection
# ======================
check_ssh_connection() {
  echo "[INFO] Checking SSH connection to $REMOTE ..."
  # With BatchMode enabled, the SSH connection will fail immediately if the key is rejected,
  # instead of failing back to a password prompt. 
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$REMOTE" "echo connected" 2>/dev/null
  if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to connect to $REMOTE using SSH key"
    exit 1
  fi
  echo "[✓] SSH connection successful."
}

# ======================
# Step 3: Prepare Temp Directory
# ======================
prepare_temp_directory() {
  TIMESTAMP=$(date +%s)
  TMP_DIR="./remote_logs_$TIMESTAMP"
  RAW_DIR="$TMP_DIR/raw"
  mkdir -p "$RAW_DIR"
  echo "[✓] Temporary directory created: $RAW_DIR"
}


# ======================
# Step 4: Copy Logs with SCP
# ======================
copy_logs() {
  echo "[INFO] Copying logs from $REMOTE:$REMOTE_DIR to $RAW_DIR ..."
  # scp copies files between hosts on a network 
  # scp uses the SFTP protocol over a ssh(1) connection for data transfer,
  # and uses the same authentication and provides the same  security as a login session.
  scp -r "$REMOTE:$REMOTE_DIR" "$RAW_DIR" 2> "$TMP_DIR/scp_errors.log"

  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then 
    echo "[!] Logs copied with warnings. Some files may have been skipped."
    echo "[!] See: $TMP_DIR/scp_errors.log"
  else
    echo "[✓] Logs copied successfully."
  fi
}

# ======================
# Step 5: Extract Archives (ZIP, TAR, TAR.GZ)
# ======================
extract_archives() {
  echo "[INFO] Scanning for compressed log archives in $RAW_DIR ..."
  
  find "$RAW_DIR" -type f \( -iname "*.zip" -o -iname "*.tar" -o -iname "*.tar.gz" \) | while read -r archive; do
    echo "[→] Extracting: $(basename "$archive")"
    case "$archive" in
      *.zip)
        unzip -o "$archive" -d "$(dirname "$archive")" > /dev/null
        ;;
      *.tar)
        tar -xf "$archive" -C "$(dirname "$archive")"
        ;;
      *.tar.gz)
        tar -xzf "$archive" -C "$(dirname "$archive")"
        ;;
    esac
  done
  echo "[✓] Archive extraction complete."
}


# ======================
# Step 6: Analyze Logs
# ======================
analyze_logs() {
  echo "[INFO] Starting keyword analysis..."

  REPORT_TXT="remote_report.txt"
  REPORT_CSV="remote_report.csv"

  echo "Remote Server: $REMOTE" > "$REPORT_TXT"
  echo "Analyzed Directory: $REMOTE_DIR" >> "$REPORT_TXT"
  echo "" >> "$REPORT_TXT"
  printf "%-25s %-12s %-6s\n" "File Name" "Keyword" "Count" >> "$REPORT_TXT"
  printf "%-25s %-12s %-6s\n" "-------------------------" "---------" "-----" >> "$REPORT_TXT"

  echo "file,keyword,count" > "$REPORT_CSV"

  declare -A total_counts

  find "$RAW_DIR" -type f -name "*.log" | while read -r logfile; do # take all log files
    filename=$(basename "$logfile") # get the file name
    for keyword in "${KEYWORDS[@]}"; do
      count=$(grep -o "$keyword" "$logfile" | wc -l)
      if [[ "$count" -gt 0 ]]; then
        printf "%-25s %-12s %-6s\n" "$filename" "$keyword" "$count" >> "$REPORT_TXT"
        echo "$filename,$keyword,$count" >> "$REPORT_CSV"
        ((total_counts["$keyword"]+=count))
      fi
    done
  done

  echo "" >> "$REPORT_TXT"
  echo "Total Keyword Matches:" >> "$REPORT_TXT"
  for keyword in "${KEYWORDS[@]}"; do
    printf "→ %-10s : %d\n" "$keyword" "${total_counts[$keyword]:-0}" >> "$REPORT_TXT"
  done
}

# ======================
# Step 7: Color Output to Terminal
# ======================
color_output() {
  echo -e "\033[1;32m[✓] Analysis complete\033[0m"
  echo -e "\033[1;34m→ TXT:\033[0m $REPORT_TXT"
  echo -e "\033[1;34m→ CSV:\033[0m $REPORT_CSV"
}


# ======================
# Main
# ======================
main() {
  START=$(date +%s)
  parse_args "$@"
  check_ssh_connection
  prepare_temp_directory
  copy_logs
  extract_archives
  analyze_logs
  color_output
  END=$(date +%s)
  echo "Total Execution Time: $(echo "$END - $START" | bc) seconds"
}



main "$@"
