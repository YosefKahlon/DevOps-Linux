#!/bin/bash

# This script automates the deployment of a Node.js web application on an Azure VM.
# It also includes a function to clean up all created resources.

# Exit on any error
set -e

# --- Configuration ---
# You can change these variables to match your desired settings.
RESOURCE_GROUP="DevOps"
LOCATION="northeurope"
VM_NAME="myVM"
VM_IMAGE="Ubuntu2204"
ADMIN_USERNAME="azureuser"
ACR_NAME="acr$(openssl rand -hex 4 | tr -d -c '[:alnum:]' | tr '[:upper:]' '[:lower:]')" # Globally unique ACR name
NSG_NAME="${VM_NAME}NSG" # Azure's default naming convention for the NSG
SSH_KEY_PATH="$HOME/.ssh/id_rsa" # Path to your SSH private key

# --- Deployment Function ---
deploy() {
    echo "Starting Azure infrastructure deployment..."

    # 1. Create Resource Group
    echo "Creating resource group: $RESOURCE_GROUP in $LOCATION..."
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

    # 2. Create Virtual Machine
    echo "Creating VM: $VM_NAME..."
    # This command also generates SSH keys if they don't exist
    az vm create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM_NAME" \
        --image "$VM_IMAGE" \
        --admin-username "$ADMIN_USERNAME" \
        --generate-ssh-keys \
        --assign-identity \
        --output none

    echo "VM created successfully."

    # 3. Get Public IP Address
    echo "Fetching Public IP address..."
    PUBLIC_IP=$(az vm show -d --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --query "publicIps" -o tsv)
    if [ -z "$PUBLIC_IP" ]; then
        echo "Error: Could not retrieve Public IP address."
        exit 1
    fi
    echo "Public IP address is: $PUBLIC_IP"

    # 4. Add NSG Rule for HTTP
    echo "Opening port 80 for HTTP traffic on NSG: $NSG_NAME..."
    az network nsg rule create \
        --resource-group "$RESOURCE_GROUP" \
        --nsg-name "$NSG_NAME" \
        --name "Allow-HTTP" \
        --protocol Tcp \
        --priority 1010 \
        --destination-port-range 80 \
        --access Allow \
        --direction Inbound \
        --output none
    echo "Port 80 is now open."

    # 5. Create Azure Container Registry
    echo "Creating Azure Container Registry: $ACR_NAME..."
    az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --output none
    echo "ACR created successfully."

    # 6. Grant VM pull access to ACR
    echo "Granting VM pull access to ACR..."
    # It can take a moment for the VM identity to be available
    sleep 60
    VM_PRINCIPAL_ID=$(az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --query "identity.principalId" -o tsv)
    ACR_ID=$(az acr show --resource-group "$RESOURCE_GROUP" --name "$ACR_NAME" --query "id" -o tsv)
    az role assignment create --assignee "$VM_PRINCIPAL_ID" --scope "$ACR_ID" --role AcrPull --output none
    echo "VM pull access to ACR granted."

    # 7. Install Docker and Azure CLI on the VM
    echo "Installing Docker and Azure CLI on the VM..."
    INSTALL_SCRIPT="sudo apt-get update && sudo apt-get install -y docker.io curl && sudo systemctl start docker && sudo systemctl enable docker && sudo usermod -aG docker ${ADMIN_USERNAME} && curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    
    az vm run-command invoke \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM_NAME" \
        --command-id RunShellScript \
        --scripts "$INSTALL_SCRIPT" \
        --output none
    echo "Docker and Azure CLI installed successfully."

    echo "-----------------------------------------------------"
    echo "Infrastructure deployment successful!"
    echo "The VM is ready for Docker deployments from ACR."
    echo "Public IP address: $PUBLIC_IP"
    echo "ACR Name: $ACR_NAME"
    echo "-----------------------------------------------------"
}

# --- Cleanup Function ---
cleanup() {
    echo "Starting cleanup..."
    echo "This will delete the entire '$RESOURCE_GROUP' resource group."
    read -p "Are you sure you want to continue? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting resource group: $RESOURCE_GROUP..."
        az group delete --name "$RESOURCE_GROUP" --yes --no-wait
        echo "Cleanup initiated. The resource group is being deleted in the background."
    else
        echo "Cleanup cancelled."
    fi
}

# --- Main Script Logic ---
# Checks for the command-line argument
if [ "$1" == "deploy" ]; then
    deploy
elif [ "$1" == "cleanup" ]; then
    cleanup
else
    echo "Usage: $0 {deploy|cleanup}"
    echo "  deploy  : Deploys the Azure resources and the web application."
    echo "  cleanup : Deletes the Azure resource group and all its resources."
    exit 1
fi
