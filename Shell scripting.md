
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