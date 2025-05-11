
#  DevOps & Linux Basics

<details>
<summary>
 Theory Tasks 
</summary>

### Outline the Agile methodology and its role in supporting DevOps practices. 

* Agile helps teams build software quickly and in small steps, while working closely together and adjusting based on feedback.

* DevOps takes those same ideas and applies them to the full process of getting software ready for users — including testing, deploying, and running it smoothly and automatically.

In short:
Agile builds fast. DevOps delivers fast. Together, they make software better and quicker for everyone.


### Study the Linux file system hierarchy (/, /etc, /var, /home) and note to yourself the purpose of each directory. 

| Directory | Purpose |
|----------|---------|
| `/`      | Root of the filesystem. Everything starts here. |
| `/etc`   | Contains configuration files (e.g., `/etc/hosts`, `/etc/passwd`). |
| `/var`   | Stores variable data like logs (`/var/log`), mail, cache. |
| `/home`  | Contains personal directories for users (`/home/username`). |

### Research 3 major benefits of adopting DevOps in software organizations and provide real‑world examples. 

✅ 1. Faster Delivery & Deployment
Benefit:
DevOps automates build, test, and deployment pipelines — letting teams release software updates quickly and frequently.

Example:
🚀 Amazon deploys code every 11.7 seconds on average using DevOps practices.
They use automation, CI/CD, and microservices to speed up innovation and respond to customer needs instantly.

✅ 2. Improved Collaboration & Efficiency
Benefit:
DevOps breaks silos between developers and operations teams. They work together, share responsibility, and communicate better.

Example:
🔧 Netflix uses DevOps to empower engineers to own the full lifecycle — from coding to running services in production.
This makes teams more accountable and reduces the "it works on my machine" problem.

✅ 3. Higher Stability & Reliability
Benefit:
DevOps uses automated testing, monitoring, and rollback systems to catch errors early and ensure reliable performance.

Example:
📊 Etsy (an online marketplace) moved from fragile, manual deployments to fully automated releases.
This improved uptime, reduced outages, and made fixing bugs faster and safer.
</details>

<summary>

<details>
<summary>
Practice Tasks
</summary>


### Use basic commands (ls, cd, pwd, mkdir, rm) to navigate and manage directories. 
``` bash 
cd ~               # Go to home directory
mkdir lab          # Create a new directory
cd lab             # Enter lab
pwd                # Print current directory
touch testfile.txt # Create file
ls                 # List files
rm testfile.txt    # Delete file
```

### Create two new users and assign them to a custom group. 

```bash
sudo adduser user1  # Create first user
sudo adduser user2  # Create second user
sudo groupadd devgroup # Create a custom group
sudo usermod -aG devgroup user1 # Add first user to the new group
sudo usermod -aG devgroup user2 # Add second user to the new group
```



### Change file and directory permissions using chmod and chown; demonstrate by creating a file owned by the group. 

```bash
touch groupfile.txt # Create file
sudo chown :devgroup groupfile.txt # Change group ownership
chmod 660 groupfile.txt # Change permissions: group can read and write
```

The command chmod sets file permissions using octal (numeric) notation.
The format is:

```css
chmod [OWNER][GROUP][OTHERS]
```
The numeric values are:
- `4` = Read (`r`)
- `2` = Write (`w`)
- `1` = Execute (`x`)

Example:
- `6` = 4 + 2 = `rw-`
- `7` = 4 + 2 + 1 = `rwx`
- `0` = No permissions


### 📖 chmod 660 Permission Dictionary

| Class  | Octal Value | Symbolic Permission | Description               |
|--------|-------------|---------------------|---------------------------|
| Owner  | `6`         | `rw-`               | Owner can read and write |
| Group  | `6`         | `rw-`               | Group can read and write |
| Others | `0`         | `---`               | No access for others     |

</details>

<details>
<summary>
Summary Task
 </summary>

# Summary Task – DevOps & Linux Basics 

Part 1: Creating Directory Structure & Permissions 

```bash 
# Step into your home directory
cd ~

# Create project1 directory
mkdir project1

# Navigate into it
cd project1

# Create docs and scripts directories
mkdir docs scripts

# Set permissions:
chmod 744 scripts    # rwxr--r--  (owner: read/write/execute, others: read only)
chmod 777 docs       # rwxrwxrwx  (everyone can read/write/execute)

```
Explanation:
* `mkdir` creates directories.

* `chmod 744` scripts makes the scripts directory accessible only to the owner for modifications (others can only read).

* `chmod 777` docs allows all users full read/write access (needed so all users can write).




Part 2: User & Group Management 
```bash
# Create user
sudo adduser devuser

# Create group
sudo groupadd devteam

# Add devuser to devteam group
sudo usermod -aG devteam devuser

# Set group ownership of project1 to devteam
sudo chgrp devteam ~/project1

# Remove group write permissions to make it read-only for devteam
sudo chmod 750 ~/project1
```
Explanation:
* `adduser` creates a new user interactively.

* `groupadd` creates a new group.

* `usermod -aG` adds an existing user to a group without removing them from others.

* `chgrp` changes the group ownership of a directory.

* `chmod 750` gives full access to owner, read+execute to group (no write), and no access to others.


```bash 
kinwon@LAPTOP-01J9JR3E:~$ ls -lR ~/project1
/home/kinwon/project1:
total 0
drwxrwxrwx 1 kinwon kinwon 512 May 10 22:53 docs
drwxr--r-- 1 kinwon kinwon 512 May 10 22:53 scripts

/home/kinwon/project1/docs:
total 0

/home/kinwon/project1/scripts:
total 0
kinwon@LAPTOP-01J9JR3E:~$ groups devuser
devuser : devuser devteam
kinwon@LAPTOP-01J9JR3E:~$
```

</details>