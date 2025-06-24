# Deployment Log

This log contains the sequence of commands executed to deploy the Azure infrastructure and the web application. It also includes troubleshooting steps taken to resolve issues.

## Initial Setup and VM Provisioning

```bash
# Login to Azure
az login

# Define variables
RESOURCE_GROUP="DevOpsSummaryRG"
LOCATION="northeurope"
VM_NAME="summaryVM"
ADMIN_USERNAME="azureuser"
VM_IMAGE="Ubuntu2204"

# Create Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Virtual Machine
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image $VM_IMAGE \
    --admin-username $ADMIN_USERNAME \
    --generate-ssh-keys
```

## Network Configuration

```bash
# Open port 80 for HTTP traffic
az vm open-port --port 80 --resource-group $RESOURCE_GROUP --name $VM_NAME --priority 900

# Get Public IP Name
# Note: The initial command `az vm show ...` failed to retrieve the IP name reliably.
# The command was updated to the one below.
PUBLIC_IP_NAME=$(az vm list-ip-addresses -g $RESOURCE_GROUP -n $VM_NAME --query "[0].virtualMachine.network.publicIpAddresses[0].name" -o tsv)

# Set the Public IP to be static
az network public-ip update --resource-group $RESOURCE_GROUP --name $PUBLIC_IP_NAME --allocation-method Static
```

## Disk Management

```bash
# Attach a new 10GB data disk
az vm disk attach --resource-group $RESOURCE_GROUP --vm-name $VM_NAME --name data-disk --new --size-gb 10 --sku Standard_LRS

# Get Public IP to connect to the VM
PUBLIC_IP=$(az vm list-ip-addresses -g $RESOURCE_GROUP -n $VM_NAME --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)

# Connect to the VM
ssh azureuser@$PUBLIC_IP
```

### Inside the VM: Disk Preparation

```bash
# Find the new disk
# Note: The initial command `lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "scsi"` failed to find the disk.
# It was replaced with the more reliable command below.
lsblk -o NAME,SIZE,MOUNTPOINT
# Output confirmed the disk was /dev/sdc

# Partition the disk
sudo parted /dev/sdc --script mklabel gpt mkpart xfspart 0% 100%

# Format the partition
sudo mkfs.xfs /dev/sdc1

# Create mount point and mount the disk
# Note: A typo initially combined these two commands. They were run separately.
# The mkdir command also failed once because the directory already existed.
sudo mkdir /datadisk
sudo mount /dev/sdc1 /datadisk

# Verify the mount
lsblk -o NAME,SIZE,MOUNTPOINT
# Output confirmed /dev/sdc1 was mounted on /datadisk

# Make the mount persistent
# First, get the UUID
sudo blkid
# UUID for /dev/sdc1 was dd90ca68-5256-47f1-acb4-9557b24b945d

# Add the entry to /etc/fstab
sudo sh -c 'echo "UUID=dd90ca68-5256-47f1-acb4-9557b24b945d /datadisk xfs defaults,nofail 1 2" >> /etc/fstab'
```

## Web Application Deployment

### Inside the VM: Installation and Setup

```bash
# Install Node.js and npm
sudo apt update
sudo apt install -y nodejs npm

# Create the server.js file
cat <<EOF | sudo tee /datadisk/server.js
const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World!\n');
});

server.listen(80, '0.0.0.0', () => {
  console.log('Server running at http://0.0.0.0:80/');
});
EOF

# Run the server in the background
sudo nohup node /datadisk/server.js &
```

## Health Check

### Inside the VM: Script Creation and Execution

```bash
# Create the healthcheck.sh script
cat <<'EOF' | sudo tee /datadisk/healthcheck.sh
#!/bin/bash

# Use curl to get the HTTP status code
STATUS_CODE=$(curl --output /dev/null --silent --write-out "%{http_code}" http://localhost)

# Check if the status code is 200
if [ "$STATUS_CODE" -eq 200 ]; then
  echo "Health Check PASSED. Server is running and accessible."
  exit 0
else
  echo "Health Check FAILED. Server returned status code $STATUS_CODE."
  exit 1
fi
EOF

# Make the script executable
sudo chmod +x /datadisk/healthcheck.sh

# Run the health check
sudo /datadisk/healthcheck.sh
# Output: Health Check PASSED. Server is running and accessible.
```

## Final Verification

```bash
# Exit the VM
exit

# Get the public IP from the local terminal
PUBLIC_IP=$(az vm list-ip-addresses -g $RESOURCE_GROUP -n $VM_NAME --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
echo $PUBLIC_IP

# Navigated to http://<PUBLIC_IP> in a browser and confirmed "Hello World!" was displayed.
```
