
# Daily Practice Tasks


<details>
<summary> Basic IP & Port Exploration  </summary>



To view your local IP address:
```bash
ifconfig
```
Quickly displays all listening TCP and UDP ports on the system without resolving names, providing a fast and clear view of active network sockets.
```bash
ss -tuln
```

`127.0.0.1:22` means the SSH service is listening on port 22,
but only accepts connections from the local machine (localhost).
127.0.0.1 is the loopback IP, and 22 is the default SSH port.

</details>


<details>
<summary> Generate SSH Key & Connect  </summary>
 

The `ssh-keygen` command is used to create an SSH key pair:

- 🔐 **Private key** – stays on your local machine
- 🔓 **Public key** – copied to the remote server

These keys allow secure, passwordless authentication over SSH.

```bash
ssh-keygen
```

Creating an RSA key
- `-t rsa` = Specifies the type of key to generate
- `-b 4096` =  Sets the strength of the key to 4096 bits
- `-f` =  Defines the file path and name to save the key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

#### We can continue after completing the [Create Azure VM (UI or CLI)](#create-azure-vm-ui-or-cli) task.


Use `ssh-copy-id` (or manual `scp`) to copy your public key to a remote VM. 

```bash
ssh-copy-id <user>@<remote-ip>
```
To Connect to the VM we using the `ssh`

```bash
ssh <user>@<vm-ip>
```

</details>


<details>
<summary> Create Azure VM (UI or CLI)  </summary>

 
Before creating a virtual machine, we need to create a new resource group that will contain the VM:

```bash
az login --tenant `TENANT_ID`

az group create --name vm-rg --location westeurope
```

Now we can create the virtual machine:



```bash
az vm create \
  --resource-group vm-rg \
  --name myLinuxVM \
  --image Ubuntu2204 \
  --admin-username yosef \
  --authentication-type ssh \
  --ssh-key-values "$(cat ~/.ssh/id_rsa.pub)" \
  --size Standard_B1s \
  --location westeurope
```

Once the VM is created, we should verify that SSH (port 22) is open.
Use the following command to list all NSG (Network Security Group) rules:

```bash
az network nsg rule list \
esource->   --resource-group vm-rg \
>   --nsg-name myLinuxVMNSG \
>   --output table
```




</details>


<details>
<summary> Remote File Transfer with SCP   </summary>



To transfer files between your **local machine** and the **VM**, we use the `scp` (Secure Copy) command.  
It works over SSH and allows both uploading and downloading files securely.

---

Create a dummy file on your **local machine**:
```bash
echo "Hello from my machine!" > myfile.txt
```
Upload the file to your VM:
```bash
scp myfile.txt <user>@<vm-ip>:/home/<user>/
```


Create a local folder to download into:
```bash
mkdir downloads
```

Download the file back from the VM:
```bash
scp <user>@<vm-ip>:/home/<user>/myfile.txt ./downloads/
```
Verify On your local machine:
```bash
cat downloads/myfile.txt
```

Verify On the VM:
```bash
cat ~/myfile.txt
```


</details>

<details>
<summary> Run a Remote Command via SSH </summary>
 

To run a command remotely without logging in manually, use the `ssh -t` command:



```bash
ssh -t <user>@<vm-ip> "uptime"
ssh -t <user>@<vm-ip> "df -h"
ssh -t <user>@<vm-ip> "ls -l /home/<user>"
```
Redirecting the output to a local file

```bash
ssh -t <user>@<vm-ip> "df -h"> vm_disk_usage.txt
```




</details>


# Remote Log Monitoring with SSH & VM


A Bash script that connects to a remote Linux server via SSH, downloads and extracts log files (including `.zip`, `.tar`, `.tar.gz`), scans them for specified keywords, and generates summary reports in both TXT and CSV formats.

---

## Features

- SSH key-only authentication (no password prompts)
- Automatic extraction of `.zip`, `.tar`, `.tar.gz`
- Scans all `.log` files recursively
- Generates two output reports:
  - `remote_report.txt` — human-readable, aligned summary
  - `remote_report.csv` — machine-readable, Excel-ready
- Colorized terminal output
-  Displays total keyword summary at the end

---

## 🧪 Example Usage

```bash
./remote_log_analyzer.sh <user@host> <remote_log_directory> ERROR WARNING CRITICAL
```

Make sure your public key is copied to the remote server with:

```bash
ssh-copy-id <user>@<remote-ip>
```