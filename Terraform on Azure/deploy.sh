#!/bin/bash

# Simpl# Function to log commands and output
log_command() {
    local step_num="$1"
    local step_desc="$2"
    local command="$3"
    
    echo "📋 Step $step_num: $step_desc..."
    
    # Log to file
    echo "Step $step_num: $step_desc" >> "$LOG_FILE"
    echo "Command: $command" >> "$LOG_FILE"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "Output:" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    
    # Execute command and capture output
    eval "$command" 2>&1 | tee -a "$LOG_FILE"
    
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
} 
# This script automates the entire infrastructure deployment process

set -e  # Exit on any error

# Create deployment log file
LOG_FILE="deployment_log.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Initialize log file
cat > "$LOG_FILE" << EOF
=== Terraform Azure VM Deployment Log ===
Deployment Date: $TIMESTAMP
Script: deploy.sh
===========================================

EOF

# Function to log commands and output
log_command() {
    local step_num="$1"
    local step_desc="$2"
    local command="$3"
    
    echo "� Step $step_num: $step_desc..."
    
    # Log to markdown file
    echo "## Step $step_num: $step_desc" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "\`\`\`bash" >> "$LOG_FILE"
    echo "$command" >> "$LOG_FILE"
    echo "\`\`\`" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "**Output:**" >> "$LOG_FILE"
    echo "\`\`\`" >> "$LOG_FILE"
    
    # Execute command and capture output
    eval "$command" 2>&1 | tee -a "$LOG_FILE"
    
    echo "\`\`\`" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

echo "�🚀 Starting Azure VM deployment with Terraform..."
echo "📝 Logging to: $LOG_FILE"

# Step 1: Initialize Terraform
log_command "1" "Initializing Terraform" "terraform init"

# Step 2: Plan the deployment
log_command "2" "Planning Terraform deployment" "terraform plan"

# Step 3: Apply the infrastructure
log_command "3" "Applying Terraform configuration" "terraform apply -auto-approve"

# Step 4: Get the VM IP address
echo "📋 Step 4: Getting VM IP address..."
VM_IP=$(terraform output -raw ip_address)
echo "✅ VM IP: $VM_IP"

# Log VM IP to file
echo "Step 4: Getting VM IP Address" >> "$LOG_FILE"
echo "Command: terraform output -raw ip_address" >> "$LOG_FILE"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "Output: $VM_IP" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Step 5: Wait for VM to be ready
echo "📋 Step 5: Waiting for VM to be ready..."
sleep 30

# Step 6: Set up web application
echo "📋 Step 6: Setting up web application..."
if [ -f "./setup-webapp.sh" ]; then
    echo "Step 6: Setting up Web Application" >> "$LOG_FILE"
    echo "Command: ./setup-webapp.sh $VM_IP TerraformDemo123" >> "$LOG_FILE"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "Output:" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    
    ./setup-webapp.sh $VM_IP TerraformDemo123 2>&1 | tee -a "$LOG_FILE"
    
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
else
    echo "⚠️  setup-webapp.sh not found, skipping web app setup"
    echo "Step 6: Setting up Web Application" >> "$LOG_FILE"
    echo "Status: setup-webapp.sh not found, skipping web app setup" >> "$LOG_FILE"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
fi

# Step 7: Run health check
echo "📋 Step 7: Running health check..."
if [ -f "./healthcheck.sh" ]; then
    echo "Step 7: Running Health Check" >> "$LOG_FILE"
    echo "Command: ./healthcheck.sh $VM_IP" >> "$LOG_FILE"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "Output:" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    
    ./healthcheck.sh $VM_IP 2>&1 | tee -a "$LOG_FILE"
    
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
else
    echo "⚠️  healthcheck.sh not found, skipping health check"
    echo "Step 7: Running Health Check" >> "$LOG_FILE"
    echo "Status: healthcheck.sh not found, skipping health check" >> "$LOG_FILE"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
fi

# Final summary
echo ""
echo "🎉 Deployment completed successfully!"
echo "🌐 VM IP Address: $VM_IP"
echo "🌐 SSH Access: ssh azureuser@$VM_IP"
echo "🌐 Web App: http://$VM_IP"
echo "📝 Deployment log saved to: $LOG_FILE"
echo ""

# Add final summary to log
echo "=== Deployment Summary ===" >> "$LOG_FILE"
echo "Status: Deployment completed successfully" >> "$LOG_FILE"
echo "VM IP Address: $VM_IP" >> "$LOG_FILE"
echo "SSH Access: ssh azureuser@$VM_IP" >> "$LOG_FILE"
echo "Web Application: http://$VM_IP" >> "$LOG_FILE"
echo "Completion Time: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "==========================" >> "$LOG_FILE"