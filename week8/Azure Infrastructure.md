# Azure Infrastructure


## Setup Azure CLI Environment

In this document, we are going to use the Azure CLI to manage Azure resources.

First, after installing and configuring the Azure CLI, you need to log in to your account:
```bash
az login
```
This command opens a browser window for you to sign in to your Azure account. After you'''ve signed in, it retrieves the tenants and subscriptions associated with your account.

The next command displays details about the currently active Azure subscription that your CLI is using:
```bash
az account show
```

## Create a Resource Group and VM via CLI

Every resource in Azure needs to be in a resource group. A resource group is a container that holds related resources for an Azure solution.

We can create one using the following command:
```bash
az group create --name DevOps --location northeurope
```
-   `--name`: You must provide a unique name for your resource group within your subscription.
-   `--location`: This is the Azure region where your resource group will be created. You can get a list of available locations using `az account list-locations -o table`. Examples of locations include `northeurope`, `westeurope`, `eastus`, `westus`, etc.

Next, we'''ll create a virtual machine (VM) inside our new resource group.
```bash
az vm create --resource-group DevOps --name myVM --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys
```
Here'''s an explanation of the parameters used in this command:
-   `--resource-group DevOps`: This specifies that the VM will be created in the `DevOps` resource group we created earlier.
-   `--name myVM`: This sets the name of the virtual machine to `myVM`.
-   `--image Ubuntu2204`: This specifies the operating system image for the VM. In this case, it'''s Ubuntu 22.04 LTS. You can find other images using `az vm image list --output table`.
-   `--admin-username azureuser`: This creates a user account on the VM with the username `azureuser`.
-   `--generate-ssh-keys`: This automatically generates SSH public and private key files and saves them in `~/.ssh`. The public key will be configured on the VM for authentication. If SSH keys already exist in the default location (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`), those keys will be used.

## Connecting to the VM

After the VM is created, you can connect to it using SSH. The output of the `az vm create` command includes the public IP address of your VM.

Based on the output you provided, your VM's public IP is `52.138.205.52`.

The `--generate-ssh-keys` flag used your existing SSH public key (`~/.ssh/id_rsa.pub`) to configure access to the new VM. The corresponding private key to connect to the VM is located at `~/.ssh/id_rsa`.

To connect to your VM, you can use the following command:
```bash
ssh azureuser@52.138.205.52
```
If that doesn't work, you may need to explicitly specify the path to your private key:
```bash
ssh -i ~/.ssh/id_rsa azureuser@52.138.205.52
```


# Configure Networking (NSG + Public IP)
In this section, we'''ll learn how to list and modify network rules for our VM using the Azure CLI. Network Security Groups (NSGs) are used to filter network traffic to and from Azure resources in an Azure virtual network. An NSG contains a list of security rules that allow or deny network traffic based on factors like source and destination IP addresses, ports, and protocols.

When you create a VM, Azure automatically creates an NSG for it, typically named `myVMNSG` if your VM is named `myVM`.

### Listing Network Rules

To see the current rules applied to your VM'''s NSG, you first need to find the name of the NSG associated with your VM. You can list the network interfaces of your VM to find the attached NSG.

First, find your Network Interface Card (NIC) name:
```bash
az network nic list --resource-group DevOps --query "[?contains(virtualMachine.id, 'myVM')].name" -o tsv
```

The previous command gives you the name of your NIC. Your output shows the name is `myVMVMNic`. You must use this exact name in the next command. The name `myVMNic` in the documentation was an example placeholder.

Now, use the NIC name you found to get the ID of the associated Network Security Group:
```bash
az network nic show --resource-group DevOps --name myVMVMNic --query "networkSecurityGroup.id" -o tsv
```
This command will give you the full ID of the NSG. The name of the NSG is the last part of the ID. Let's assume the NSG name is `myVMNSG`.

Now you can list the rules for that NSG:
```bash
az network nsg rule list --resource-group DevOps --nsg-name myVMNSG -o table
```

### Adding a Rule to Allow HTTP Traffic

By default, only SSH traffic is allowed. To allow incoming HTTP traffic to our VM (for example, if we want to run a web server), we need to create a new rule in the NSG.

Here is the command to add a rule that allows HTTP traffic on port 80:

```bash
az network nsg rule create \
    --resource-group DevOps \
    --nsg-name myVMNSG \
    --name Allow-HTTP \
    --protocol Tcp \
    --priority 1010 \
    --destination-port-range 80 \
    --access Allow \
    --direction Inbound
```

Explanation of the parameters:
-   `--resource-group DevOps`: The resource group containing the NSG.
-   `--nsg-name myVMNSG`: The name of the Network Security Group.
-   `--name Allow-HTTP`: The name of the new rule.
-   `--protocol Tcp`: The protocol for the rule (TCP for HTTP).
-   `--priority 1010`: A number between 100 and 4096. Rules are processed in priority order. Lower numbers are processed first. It'''s a good practice to leave gaps between priority numbers to allow for adding more rules later.
-   `--destination-port-range 80`: The port the traffic is destined for.
-   `--access Allow`: This rule allows traffic.
-   `--direction Inbound`: The rule applies to inbound traffic.

### Verifying Network Configuration

You can use the following commands to get more details about your VM'''s network configuration:

-   **Show Public IP details:** This command shows information about the public IP address of your VM, including the IP address, allocation method, and domain name label. You can find your public IP name with `az network public-ip list --resource-group DevOps -o table`.

    ```bash
    az network public-ip show --resource-group DevOps --name myVMPublicIP -o table
    ```

-   **List Network Interfaces:** This command lists the network interface cards (NICs) in the resource group.
    ```bash
    az network nic list --resource-group DevOps -o table
    ```

## Deploy a Simple Web App to the VM

Now that we have a VM and have opened port 80, let's deploy a simple Node.js web application. We will use `scp` to copy the web app files to the VM and then use `az vm run-command` to install Node.js, install dependencies, and run the application.

### 1. Create a Simple Node.js Web App

First, create a simple Node.js application. I have already created the following files for you in the `week8/simple-web-app` directory:
-   `index.html`: The main page of your web app.
-   `app.js`: A simple Node.js server to serve the `index.html` file.
-   `package.json`: Defines the project metadata and dependencies.

### 2. Copy the Web App to the VM

Now, we will use the `scp` command to securely copy the `simple-web-app` directory to your VM's home directory.

**Note:** The command below assumes you are in the `week8` directory. If you are in another directory, you will need to adjust the path to the `simple-web-app` directory accordingly.

```bash
scp -r -i ~/.ssh/id_rsa simple-web-app azureuser@52.138.205.52:~
```

### 3. Install and Configure a Web Server and Node.js

Next, we will use the `az vm run-command` to execute a script on the VM. This script will:
1.  Update the package lists.
2.  Install Nginx and Node.js.
3.  Set up a reverse proxy to forward traffic from port 80 to your Node.js app running on port 3000.
4.  Navigate into the `simple-web-app` directory.
5.  Install the application dependencies using `npm install`.
6.  Start the Node.js application using `npm start`.

```bash
az vm run-command invoke \
    --resource-group DevOps \
    --name myVM \
    --command-id RunShellScript \
    --scripts "sudo apt-get update && sudo apt-get install -y nginx nodejs npm && sudo systemctl start nginx && sudo systemctl enable nginx && echo 'server { listen 80; server_name _; location / { proxy_pass http://localhost:3000; proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection '\\''upgrade'\\''; proxy_set_header Host \$host; proxy_cache_bypass \$http_upgrade; } }' | sudo tee /etc/nginx/sites-available/default && sudo nginx -s reload && cd /home/azureuser/simple-web-app && npm install && nohup npm start &"
```

### 4. Access Your Web App

Once the command has finished, you should be able to access your web app by navigating to your VM's public IP address in your web browser:

[http://52.138.205.52](http://52.138.205.52)

# Use Storage Account

In this section, we'll create an Azure Storage Account, create a container within it, and upload a file.

### 1. Create a Test File

First, I've created a `test.txt` file in the `week8` directory for you to upload.

### 2. Create a Storage Account

Now, let's create a new storage account in our `DevOps` resource group. Storage account names must be globally unique, so we'll use a random number to help with that.


```bash
az storage account create \
  --name devopsstorage10938 \
  --resource-group DevOps \
  --sku Standard_LRS
```

### 3. Create a Container

Next, we'll create a container named `mycontainer` inside our new storage account.

```bash
az storage container create \
  --name mycontainer \
  --account-name devopsstorage10938
```

### 4. Assign Permissions for Upload

The error "You do not have the required permissions" occurs because your user account doesn't have the necessary role assignment on the storage account to upload data when using `--auth-mode login`. We need to assign the "Storage Blob Data Contributor" role to your user.

It can take a minute or two for role assignments to propagate in Azure.

First, get your user's principal ID and store it in a variable. This command gets the object ID of the currently signed-in user.
```bash
PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
```

Next, get the full resource ID of the storage account and store it in a variable. This will be used as the scope for the role assignment.
```bash
SCOPE=$(az storage account show --name devopsstorage10938 --resource-group DevOps --query id -o tsv)
```

Now, create the role assignment. This command grants your user the "Storage Blob Data Contributor" role on the `devopsstorage10938` storage account.
```bash
az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee $PRINCIPAL_ID \
    --scope $SCOPE
```

After running these commands, **wait for a minute or two** for the permissions to apply before proceeding.

### 5. Upload a File to the Container

Now that you have the correct permissions, you can upload the `test.txt` file.

```bash
az storage blob upload \
  --account-name devopsstorage10938 \
  --container-name mycontainer \
  --name test.txt \
  --file week8/test.txt \
  --auth-mode login
```

### 6. Verify the Upload

Finally, you can list the blobs in the container to verify that the file was uploaded successfully.

```bash
az storage blob list \
  --account-name devopsstorage10938 \
  --container-name mycontainer \
  --auth-mode login \
  --output table
```

## Script the Entire Deployment

To automate the entire process of creating the infrastructure, deploying the web application, and cleaning up the resources, we have created a bash script named `deploy.sh`.

This script provides two main functions:
-   `deploy`: Creates the resource group, virtual machine, configures the network security group, copies the web application files, and runs the application on the VM.
-   `cleanup`: Deletes the entire resource group, which removes all the resources created during the deployment.

### The `deploy.sh` Script

Here is the full content of the `deploy.sh` script. It is located in the `week8` directory.

```bash
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
NSG_NAME="${VM_NAME}NSG" # Azure's default naming convention for the NSG
SSH_KEY_PATH="$HOME/.ssh/id_rsa" # Path to your SSH private key
WEB_APP_PATH="week8/simple-web-app" # Path to the web app source code

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

    # 5. Copy Web Application to VM
    echo "Waiting for VM to be ready for SSH connection..."
    sleep 20 # A simple wait. For production, a more robust check is needed.
    
    echo "Copying web application files from '$WEB_APP_PATH' to VM..."
    scp -r -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o ConnectionAttempts=60 "$WEB_APP_PATH" "${ADMIN_USERNAME}@${PUBLIC_IP}:~"
    echo "Web app files copied."

    # 6. Deploy Application on VM
    echo "Installing dependencies and starting the web server on the VM..."
    # This long command installs nginx, node, npm, configures a reverse proxy, and starts the app
    DEPLOY_SCRIPT="sudo apt-get update && sudo apt-get install -y nginx nodejs npm && sudo systemctl start nginx && sudo systemctl enable nginx && echo 'server { listen 80; server_name _; location / { proxy_pass http://localhost:3000; proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection '\\''upgrade'\\''; proxy_set_header Host \$host; proxy_cache_bypass \$http_upgrade; } }' | sudo tee /etc/nginx/sites-available/default && sudo nginx -s reload && cd /home/azureuser/simple-web-app && npm install && nohup npm start &"
    
    az vm run-command invoke \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM_NAME" \
        --command-id RunShellScript \
        --scripts "$DEPLOY_SCRIPT" \
        --output none
    echo "Application deployed and running."

    echo "-----------------------------------------------------"
    echo "Deployment successful!"
    echo "You can now access your web app at: http://$PUBLIC_IP"
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

```

### How to Use the Script

To run the script, navigate to the root directory of the repository and use the following commands.

**To deploy the infrastructure and application:**
```bash
bash week8/deploy.sh deploy
```

**To clean up all resources:**
```bash
bash week8/deploy.sh cleanup
```
This will prompt you for confirmation before deleting the resource group.