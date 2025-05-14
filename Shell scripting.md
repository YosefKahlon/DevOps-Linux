
 
 # Daily Practice Tasks

 <details>
<summary> Hello DevOps Script </summary>



1. Open a new file with Vim

```bash
vi hello_devops.sh
```
2. Enter Insert mode by pressing `i`.
```vim
#!/bin/bash  #Bash scripts start with a shebang
echo "Hello DevOps"
```
3. Press `Esc` to exit Insert mode.
4. Type `:wq` to save and quit.
5. Make the script executable:
```bash
chmod +x hello_devops.sh
```
6. Run the script:
```bash
./hello_devops.sh
```

 </details>

---------

 <details>
<summary> File & Directory Checker </summary>
 
```bash
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

```

 </details>

 -----


 <details>
<summary> List Files with Sizes </summary>
  

 

```bash
#!/bin/bash

printf "%-30s %10s\n" "Filename" "Size (KB)"
printf "%-30s %10s\n" "--------" "----------"

for file in *; do # Loop through all files in the current directory
  if [ -f "$file" ]; then
    size_bytes=$(stat %s "$file")         # Get size in bytes
    size_kb=$(( (size_bytes + 1023) / 1024 )) # Round up to next KB
    printf "%-30s %10s\n" "$file" "$size_kb"
  fi
done
```
The ```stat```  providing detailed statistics about files and file systems 


The ```c%s```   use the specified FORMAT with total size, in bytes




```bash 

chmod +x list_files_with_sizes.sh
./list_files_with_sizes.sh

Filename                        Size (KB)
--------                       ----------
file_directory_checker.sh               1
hello_devops.sh                         1
list_files_with_sizes.sh                1
```

</details>

----




<details>
<summary> Search for ERROR Logs </summary> 



```bash

#!/bin/bash
log_file="access.log"

if [ ! -f "$log_file" ]; then 
  echo "File $log_file not found!"
  exit 1
fi

echo "Lines containing 'ERROR':"
grep "ERROR" "$log_file" #search for the word ERROR

echo
count=$(grep -o "ERROR" "$log_file" | wc -l) 
echo "Total 'ERROR' occurrences: $count"

```

```grep```  searches  for PATTERNS in each FILE.

```-o```, ```--only-matching```
              Print  only the matched (non-empty) parts of a matching  
              line, with each such part on a separate output line. 

```-l```, ```--lines```
              print the newline counts



```bash
chmod +x search_error_logs.sh
./search_error_logs.sh

Lines containing 'ERROR':
2025-05-13 12:00:03 [ERROR] Failed to connect to database
2025-05-13 12:00:09 [ERROR] Invalid user credentials

Total 'ERROR' occurrences: 2
```
</details>

---

<details>
<summary> AWK Column Extractor  </summary> 

 Sample `data.csv`

```csv
id,name,age
1,Alice,30
2,Bob,25
3,Charlie,28
4,David,40
5,Eve,22
```


```bash
awk -F',' '{print $2}' data.csv
```

```awk``` A scripting tool for pattern scanning and text processing

```-F','``` Sets the field separator to a comma ```,```, since it's a CSV

```{print $2}``` Prints the second column from each row. 


</details>











#  Daily Practice Tasks