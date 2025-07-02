#!/bin/bash

# Script to set up a simple web application on the VM
# Usage: ./setup-webapp.sh <VM_IP> <SSH_PASSWORD>

VM_IP="$1"
SSH_PASSWORD="$2"

if [ -z "$VM_IP" ] || [ -z "$SSH_PASSWORD" ]; then
    echo "Usage: $0 <VM_IP> <SSH_PASSWORD>"
    echo "Example: $0 4.180.86.58 TerraformDemo123"
    exit 1
fi

echo "Setting up web application on VM at $VM_IP..."

# Create a script to run on the remote VM
cat > setup_commands.sh << 'EOF'
#!/bin/bash

# Update package lists
sudo apt update

# Install nginx web server
sudo apt install -y nginx

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create a simple HTML page
DEPLOY_DATE=$(date)
sudo tee /var/www/html/index.html > /dev/null << HTML
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Demo Web App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin: 50px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            margin: 0 auto;
        }
        h1 {
            color: #2c3e50;
        }
        p {
            color: #34495e;
            font-size: 18px;
        }
        .status {
            background-color: #27ae60;
            color: white;
            padding: 10px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Terraform Azure VM Demo</h1>
        <div class="status">Web Application is Running Successfully!</div>
        <p>This web application is running on an Azure VM deployed with Terraform.</p>
        <p><strong>Server:</strong> Ubuntu 20.04 LTS</p>
        <p><strong>Web Server:</strong> Nginx</p>
        <p><strong>Deployment:</strong> Infrastructure as Code</p>
        <hr>
        <p><em>Deployed on: $DEPLOY_DATE</em></p>
    </div>
</body>
</html>
HTML

# Check nginx status
sudo systemctl status nginx --no-pager

echo "Web application setup completed!"
echo "You can now access the web app at http://$(curl -s ifconfig.me || hostname -I | awk '{print $1}')"
EOF

# Copy the script to the remote VM and execute it
echo "Copying setup script to VM..."
sshpass -p "$SSH_PASSWORD" scp -o StrictHostKeyChecking=no setup_commands.sh azureuser@$VM_IP:/tmp/

echo "Executing setup script on VM..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no azureuser@$VM_IP "chmod +x /tmp/setup_commands.sh && /tmp/setup_commands.sh"

# Clean up
rm setup_commands.sh

echo ""
echo "Setup completed! Testing web application..."
sleep 5

# Test the web application
if curl -s --connect-timeout 10 http://$VM_IP > /dev/null; then
    echo "Web application is now accessible at http://$VM_IP"
else
    echo "Web application is still not responding. Checking firewall..."
    echo "You may need to configure Azure Network Security Group to allow HTTP traffic on port 80."
fi