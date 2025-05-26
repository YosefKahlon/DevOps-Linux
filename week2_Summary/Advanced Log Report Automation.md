# Advanced Automated Log Report Generator

This Bash script analyzes `.log` files in a given directory, counts occurrences of specific keywords, and generates a professional report in either `.txt` or `.csv` format.

## Features

- Accepts a log directory as input
- Supports multiple keywords via the `--keywords` flag
- Generates a clean, tabular report per log file
- Supports recursive scanning of subdirectories
- Exports report in `.txt` or `.csv` format
- Displays total execution time
- Well-structured with modular functions



## How to Use

### Basic Usage
```bash

./advanced_log_report.sh ./logs --keywords ERROR CRITICAL WARNING INFO
```

Explains usage instructions
```bash
./advanced_log_report.sh ./logs --help
```

With Format Selection (txt or csv)
```bash
./advanced_log_report.sh /path/to/logs --keywords ERROR CRITICAL --format csv
```


With Recursive Directory Scanning
```bash
./advanced_log_report.sh /path/to/logs --keywords ERROR WARNING --recursive
```


# Code 

See full script in [advanced_log_report.sh](./advanced_log_report.sh)

## 📄 Example Output (TXT)

Log File: app1.log
| Keyword   | Occurrences |
|-----------|-------------|
| ERROR     | 3           |
| WARNING   | 1           |

Total Execution Time: .060921088 seconds

