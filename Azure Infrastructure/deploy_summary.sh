#!/bin/bash

# This script automates the deployment of a Node.js web application on an Azure VM.
# It also includes a function to clean up all created resources.

# Exit on any error
set -e

# --- Configuration ---
# You can change these variables to match your desired settings.
RESOURCE_GROUP="DevOpsSummaryRG"
LOCATION="northeurope"
VM_NAME="summaryVM"
ADMIN_USERNAME="azureuser"
VM_IMAGE="Ubuntu2204"
DISK_NAME="data-disk"

# --- Deployment Function ---
deploy() {
    echo "Starting Azure infrastructure deployment..."

    # 1. Create Resource Group
    echo "Creating resource group: $RESOURCE_GROUP in $LOCATION..."
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

    # 2. Create Virtual Machine
    echo "Creating VM: $VM_NAME..."
    az vm create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM_NAME" \
        --image "$VM_IMAGE" \
        --admin-username "$ADMIN_USERNAME" \
        --generate-ssh-keys \
        --output none

    echo "VM created successfully."

    # 3. Open port 80 for HTTP
    echo "Opening port 80 for HTTP traffic..."
    az vm open-port --port 80 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --priority 900 --output none

    # 4. Assign Static Public IP
    echo "Assigning static public IP..."
    PUBLIC_IP_NAME=$(az vm list-ip-addresses -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "[0].virtualMachine.network.publicIpAddresses[0].name" -o tsv)
    az network public-ip update --resource-group "$RESOURCE_GROUP" --name "$PUBLIC_IP_NAME" --allocation-method Static --output none
    PUBLIC_IP=$(az network public-ip show --resource-group "$RESOURCE_GROUP" --name "$PUBLIC_IP_NAME" --query "ipAddress" -o tsv)
    echo "Static Public IP is: $PUBLIC_IP"

    # 5. Attach a Persistent Data Disk
    echo "Attaching a 10GB data disk..."
    az vm disk attach \
        --resource-group "$RESOURCE_GROUP" \
        --vm-name "$VM_NAME" \
        --name "$DISK_NAME" \
        --new \
        --size-gb 10 \
        --sku Standard_LRS \
        --output none

    echo "Data disk attached."

    # 6. Prepare and Mount Disk and Deploy App on VM
    echo "Connecting to VM ($PUBLIC_IP) to set up the disk and deploy the application..."
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ADMIN_USERNAME@$PUBLIC_IP" << 'EOF'
        set -e
        echo "Preparing and mounting the data disk..."
        # Find disk, partition, format
        sudo parted /dev/sdc --script mklabel gpt mkpart xfspart 0% 100%
        sudo mkfs.xfs /dev/sdc1
        # Mount and add to fstab
        sudo mkdir /datadisk
        sudo mount /dev/sdc1 /datadisk
        UUID=$(sudo blkid -s UUID -o value /dev/sdc1)
        echo "UUID=$UUID /datadisk xfs defaults,nofail 1 2" | sudo tee -a /etc/fstab

        echo "Installing Node.js..."
        sudo apt-get update -y > /dev/null
        sudo apt-get install -y nodejs npm > /dev/null

        echo "Creating the web server application..."
        cat <<'EOT' | sudo tee /datadisk/server.js
const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello from your automated deployment!\n');
});

server.listen(80, '0.0.0.0', () => {
  console.log('Server running at http://0.0.0.0:80/');
});
EOT

        echo "Starting the web server..."
        sudo nohup node /datadisk/server.js > /dev/null 2>&1 &
        echo "Web server started."
EOF

    echo "-----------------------------------------------------"
    echo "Deployment successful!"
    echo "You can access your web app at: http://$PUBLIC_IP"
    echo "-----------------------------------------------------"
}

# --- Cleanup Function ---
cleanup() {
    echo "Are you sure you want to delete the resource group '$RESOURCE_GROUP'?"
    read -p "This will delete all resources within it. (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Deleting resource group: $RESOURCE_GROUP..."
        az group delete --name "$RESOURCE_GROUP" --yes --no-wait
        echo "Resource group deletion initiated in the background."
    else
        echo "Cleanup cancelled."
    fi
}

# --- Main Logic ---
if [ "$1" == "deploy" ]; then
    deploy
elif [ "$1" == "cleanup" ]; then
    cleanup
else
    echo "Usage: $0 [deploy|cleanup]"
    exit 1
fi
